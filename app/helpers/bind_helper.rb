module BindHelper

  def bind(object_options)
    BindOptions.new(object_options)
  end

  def bind_to(object_options, event)
    BindOptions.new(nil, object_options, event)
  end

  class BindOptions
    attr_accessor :name, :to, :event

    def initialize(options, to = nil, event = nil)
      @name = options
      @to = to
      @event = event
    end

    def parse(options)
      case options
      when NilClass
        nil
      when String, Fixnum
        options.to_s
      when Array
        options.map do |obj|
          case obj
          when NilClass
            nil
          when String, Fixnum
            obj.to_s
          else
            obj.object_id
          end
        end.join('-')
      else
        options.object_id
      end
    end

    def to_options
      {
        "bind-id" => parse(@name),
        "bind-event" => @event,
        "bind-to" => parse(@to)
      }
    end

    def to_jquery(target = :name)
      "[bind-id=#{parse(send(target))}]"
    end
  end
end

