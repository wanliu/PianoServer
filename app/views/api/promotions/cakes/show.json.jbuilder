json.extract! @cake, *Cake::DELEGATE_ATTRS, :item_id, :id, :hearts_limit

json.buyers @birthday_parties do |party|
  json.extract! party.user, :nickname, :avatar_url
  json.party_url birthday_party_path(party)
end
