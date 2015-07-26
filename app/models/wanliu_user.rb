require 'active_resource'
class WanliuUserCollection < ActiveResource::Collection
  def initialize(parsed = {})
    @elements = parsed['users']
  end
end

class WanliuUser < ActiveResource::Base
	self.site = Settings.wanliu.backend
	self.element_name = 'users'
  self.collection_parser = WanliuUserCollection

end
