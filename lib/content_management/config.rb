require "singleton"

module ContentManagement
  extend self

  def setup(&block)
    @config ||= Config.instance

    yield(Config.instance)
  end

  class Config < OpenStruct
    include Singleton

    def self.options
      instance
    end
  end
end
