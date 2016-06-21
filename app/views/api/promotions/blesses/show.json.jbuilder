json.extract! @bless, *@bless.attribute_names
json.sender @bless.sender, :id, :avatar_url, :login
json.virtual_present @bless.virtual_present, :name, :id