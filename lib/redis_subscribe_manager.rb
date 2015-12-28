
module RedisSubscribeManager
  @redis = Redis::Objects.redis
  @redis.config 'SET', 'notify-keyspace-events', 'KEA'
  puts 'Loading RedisSubscribeManager...'
  pubsub = @redis.pubsub
  pubsub.psubscribe '__key*__:*' do |channel, msg|
    puts channel, msg
  end

  cattr_accessor :listenings

  @@listenings =  []

  class << self

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

    private

    def __process_events(on)
      on.subscribe do |channel, subscriptions|
        puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
      end

      on.message do |channel, message|
        puts "##{channel}: #{message}"
        redis.unsubscribe if message == "exit"
      end

      on.unsubscribe do |channel, subscriptions|
        puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
      end
    end
  end
end
