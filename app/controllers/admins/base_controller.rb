class Admins::BaseController < ApplicationController
	layout "admins"

	before_action :authenticate_admin!

  before_action :admins_page_info

  def admins_page_info
    self.page_title += [ '工作后台' ]
    self.page_navbar = '工作后台'
    self.page_navbar_link = "/admins"
  end

  def primary_title

  end

  def subtitle
  end
end
