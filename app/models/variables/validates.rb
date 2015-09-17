module Variables
  module Validates

    def self.included(klass)
      klass.validates :name, presence: true
    end
  end
end
