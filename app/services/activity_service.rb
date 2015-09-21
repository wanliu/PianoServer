module ActivityService
  extend self

  def current_user
    Proc.new{ |controller, model| controller.current_user }
  end

  def system_admin
    Proc.new{ |controller, model| Admin.new(id: 0) }
  end
end
