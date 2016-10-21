json.extract! @cake, *Cake::DELEGATE_ATTRS, :item_id, :id, :hearts_limit, :supplier
json.is_deleted @cake.deleted?
json.is_sales_man @is_sales_man

json.buyers @birthday_parties do |party|
  json.extract! party.user, :nickname, :avatar_url
  json.party_id party.id
# json.party_url birthday_party_path(party)
end
