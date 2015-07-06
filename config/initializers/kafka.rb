module Live
  module Producer
    Producer = Poseidon::Producer.new(["localhost:9092"], "live_producer")
    

    def self.send_match_message(payload)
      messages = [Poseidon::MessageToSend.new("matching", payload)]
      Producer.send_messages(messages)
    end

    def self.send_participant_message(payload)
      messages = [Poseidon::MessageToSend.new("partic", payload)]
      Producer.send_messages(messages)
    end
  end
end