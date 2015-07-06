module MessageSystem
  class Service
  end

  @@service = Service.new

  module Error
    class InvalidArgumentError < StandardError; end
  end

  class << self 
    include ActionView::Helpers::AssetUrlHelper

    def push(room_or_id, user_or_id, *args)
      options = args.extract_options!
      if args.count == 2
        target_or_id = args.shift
        message = args.shift
      elsif args.count == 1
        message = args.shift
      else 
        raise Error::InvalidArgumentError.new('you must pass target_or_id, message params')
      end

      target_id = target_or_id.is_a?(User) ? target_or_id.id : target_or_id
      room_id = room_or_id.is_a?(Room) ? room_or_id.id : room_or_id

      user_id, image = if user_or_id.is_a?(Symbol) && user_or_id == :system
                         [ 0, {avatar_url: Settings.system.agent.image.avatar_url }]
                       elsif user_or_id.is_a?(User)
                         [ user_or_id.id ]
                       else
                         [ user_or_id ]
                       end

      msg_options = {      
        messable_id: room_id,
        messable_type: 'Room', 
        from_id: user_id, 
        reply_id: target_id,
        text: message
      }
      
      msg_options.merge! image: image unless image.blank?

      Message.create(msg_options)
      puts *args
    end
  end

end
