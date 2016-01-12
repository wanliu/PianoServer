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
      trap(:INT) { puts; exit }
      puts 'Loading RedisSubscribeManager...'

      monitor_model("OneMoney")
      monitor_model("PmoItem")
      monitor_model("PmoGrab")

    end

    def monitor_model(model, db = 0, pattern = "$keyspace:$model:$id:__expires:$field")
      parse_method = lambda do |template|
        parts = {}

        template.split(':').each_with_index do |key, i|
          if key[0] == '$'
            parts[key[1..-1]] = i
          end
        end

        return lambda do |msg, block|
          msgs = msg.split(':')
          args = *([parts["model"], parts["id"], parts["field"]].map { |i| msgs[i] })
          block.call *args
        end
      end.call(pattern)


      # pattern_names = "__keyspace@#{db}__:#{model}:*:__expires:*"
      pattern_names = "__key*__:*"
      psubscribe pattern_names do |channel, msg, status|
        Rails.logger.info("on_message #{channel} #{msg} #{status}") if status == "expired"

        meth = lambda do |model_name, id, field|
          if status == "expired"
            instantialize(model_name, id) do |instance|
              try_callback(instance, field) do |model|
                Rails.logger.debug "Expire #{model_name}.#{id} events: #{field}"
              end
            end
          end
        end

        parse_method.call msg, meth
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

    def psubscribe(pattern, &block)
      Thread.new do
        begin
          self.redis = Redis.new(url: redis_url)
          @redis = self.redis
          if @redis.config("set", "notify-keyspace-events", "KEA")
            Rails.logger.info "Subscribe #{pattern}"
            @redis.psubscribe pattern do |on|
              on.pmessage &block
            end
          else
            Redis::BaseConnectionError.new('config is error')
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

    private

    def parse_key(msg)
      namespace, model, id, field = msg.split(':')
      if namespace.start_with? '__keyspace@'
        [model, id, field]
      else
        [nil, nil, nil]
      end
    end

    def instantialize(model_name, id, &block)
      klass = model_name.safe_constantize
      yield klass[id] if block_given? and klass.is_a?(Class)
    end
    #
    # def try_model(hash, &block)
    #   model = hash[:model].to_s
    #   klass = model.classify.safe_constantize
    #   yield klass.new(hash[:id]) if block_given? and klass.is_a?(Class)
    # end
    #
    def try_callback(model, field, &block)
      if model.respond_to?(:run_callbacks)
        model.run_callbacks field do
          yield model if block_given?
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
