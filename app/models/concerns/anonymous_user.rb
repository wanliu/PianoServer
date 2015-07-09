module AnonymousUser
  extend ActiveSupport::Concern

  included do 

    scope :anonymous, -> (&block) do 
      User.new(id: -(Time.now.to_i + rand(10000)), &block)
    end
  end
end
