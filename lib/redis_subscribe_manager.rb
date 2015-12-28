
module RedisSubscribeManager
  # autoload :OneMoney, 'one_money'

  cattr_accessor :listenings
  cattr_accessor :redis

  @@listenings =  []

  class << self
    attr_accessor :events_queue


    def subscribe(event, &block)
      self.listenings.push(event: event, block: block)
    end

    def unsubscribe(event)
      self.listenings.resevse.each_index do |listen, index|
        if listenr[:event] == event
          self.listenings.delete_at(self.listenings.count - index)
          break
        end
      end
    end

    def launch
      # require 'em-synchrony'
      # require 'em-synchrony/em-hiredis'
      trap(:INT) { puts; exit }

      Thread.new do
        begin
          self.redis = Redis.new(url: redis_url)
          @redis = self.redis
          puts 'Loading RedisSubscribeManager...'

          @redis.psubscribe '__key*__:*' do |on|
            on.pmessage do |channel, msg|
              parse_twice_message(msg) do |_model|
                try_callback(_model) do |model|
                  Rails.logger.debug "expire #{_model}"
                end
              end
              true
            end
          end
        rescue Redis::BaseConnectionError => error
          puts "#{error}, retrying in 1s"
          sleep 1
          retry
        rescue e
          puts e
        end
      end
    end

    def redis_url
      redis_config = Rails.application.config.redis_config
      host = redis_config["host"]
      port = redis_config["port"]
      db = redis_config["db"] || '0'
      auth = redis_config['auth'] ? ":#{redis_config['auth']}@" : ''
      url = "redis://#{auth}#{host}:#{port}/#{db}"
    end

    private

    def parse_key(msg)
      namespace, model, id, field = msg.split(':')
      if namespace.start_with? '__keyspace@'
        [model, id, field]
      else
        [nil, nil, nil]
      end
    end

    def parse_event(msg, event = 'expired')
      namespace, _event = msg.split(':')
      return namespace.start_with?('__keyevent@') && _event == event
    end

    def parse_twice_message(msg, &block)
      # puts msg
      _model, id, field = parse_key(msg)
      if _model && id && field
        events_queue.push({model: _model, id: id, field: field})
      elsif parse_event(msg)
        model = events_queue.pop()
        yield model if block_given? and model.present?
      end
    end

    def events_queue
      @events_queue ||= []
    end

    def try_model(hash, &block)
      model = hash[:model].to_s
      klass = model.classify.safe_constantize
      yield klass.new(hash[:id]) if block_given? and klass.is_a?(Class)
    end

    def try_callback(hash, &block)
      try_model(hash) do |model|
        if model.respond_to?(:run_callbacks)
          model.run_callbacks hash[:field] do
            yield model if block_given?
          end
        end
      end
    end
  end
end

if Rails.env.production? && ENV['SUBSCRIBE_MASTER']
  RedisSubscribeManager.launch
elsif Rails.env.development?
  RedisSubscribeManager.launch
end
