module AnonymousUser
  extend ActiveSupport::Concern

  included do

    scope :anonymous, -> (id = nil, &block) do
      User.new id: id.nil? ? (-Time.now.to_i + rand(10000)) : id do |u|
        u.created_at = Time.now
        u.updated_at = Time.now
        u.username = "游客#{u.id.abs}"

        self.instance_eval {
          block.call(u) unless block.nil?
        }
      end
    end
  end

  def anonymous?
    id < 0
  end
end
