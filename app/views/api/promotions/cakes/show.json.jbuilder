json.extract! @cake, *Cake::DELEGATE_ATTRS, :item_id, :id, :hearts_limit
json.buyers @buyers do |buyer|
  json.extract! buyer, :login, :avatar_url
end
