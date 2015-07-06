module Accepting
  # handshank = Accepting::HandShank.new(room.acceptings)
  # handshank.accepting(current_user)
  # handshank.is_single?
  # 
  # handshank.is_
  # 
  class HandShank

    def initialize(record, key)
      @target = record
      if record.send(key).nil?
        record.send("#{key}=".to_sym, {})
        record.save()
      end
      @acceptings = @target.send(key)
    end

    def accepting(user_id, time = Time.now)
      puts @acceptings, @acceptings[user_id.to_s]
      @acceptings[user_id.to_s.to_sym] = {
        time: time
      }
      @target.save
    end

    def is_single?
      @acceptings.keys.count <= 1
    end

    def is_double?
      @acceptings.keys.count > 1
    end
  end
end
