require 'active_resource'
class Promotion < ActiveResource::Base
  self.site = Settings.wanliu.backend

end
