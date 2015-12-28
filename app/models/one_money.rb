class OneMoney
  include Redis::Objects
  include ActiveSupport::Callbacks
  define_callbacks :start_at, :end_at, :suspend

  set_callback :start_at, :after, :expired_start_at
  set_callback :end_at, :after, :expired_end_at

  # hash_key :info, global: true
  #
  value :name
  value :title
  value :description
  value :created_at, marshal: true
  value :updated_at, marshal: true

  value :start_at, marshal: true
  value :end_at, marshal: true

  value :cover_url
  value :status

  value :price

  counter :executies
  counter :items

  def initialize(id = nil)
    if id
      @id = id
    end
  end

  def id
    @id ||= self.redis.incr('one_money_count')
  end

  def set_time_event(time, field)
    key_name = ['one_money', id, field].join(':')
    redis.expireat(key_name, time.to_i) if redis.ttl(key_name) < 0
  end

  class << self
    def page(step = 0)
      keys = self.redis.keys 'one_money:*:*'
      keynames = keys.map {|keyname| keyname.split ':' }
      key_groups = keynames.group_by { | _, id, attr| id }
      key_groups.map { |id, values|
        new id
      }
    end

    def per(_per = 25)
      _per
    end
  end

  private

  def expired_start_at
    status.set 'started'
  end

  def expired_end_at
    status.set 'end'
  end
end
