class Api::BaseController < ::ActionController::API
# class Api::BaseController < ::ActionController::Base
  include ActionController::ImplicitRender
  include ActionController::Helpers
  # 使 ActiveModelSerializer 在 render json hook 生效
  # include ActionController::Serialization
  # 安装 token authenticatable 
  include TokenAuthenticatable
  include JSONOptions

  helper ApplicationHelper
 
  before_action :authenticate_user!

  respond_to :json, :html

  json_default_config :simple

  json_options

  def render_json_partial(record, highlight, template)
    view = ActionView::Base.new(ActionController::Base.view_paths, {})
    view.class_eval do
      include ApplicationHelper
      include TextHelper
      include Rails.application.routes.url_helpers
    end
    view.render(partial: template, locals: {source: record, highlight: highlight}, handlers: [:jbuilder])
  end
end
