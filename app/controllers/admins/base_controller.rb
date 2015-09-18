class Admins::BaseController < ApplicationController
	layout "admins"

	before_action :authenticate_admin!

  before_action :admins_page_title

  def admins_page_title
    self.page_title += [ '工作后台' ]
  end
end
