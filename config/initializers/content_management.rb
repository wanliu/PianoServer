require 'content_management'

ContentManagement.setup do |config|
  config.root = Settings.sites.root
end
