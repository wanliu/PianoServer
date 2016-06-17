json.extract! @cake, *Cake::DELEGATE_ATTRS
json.buyers @buyers do |buyer|
  json.extract! buyer, :login, :avatar_url
end