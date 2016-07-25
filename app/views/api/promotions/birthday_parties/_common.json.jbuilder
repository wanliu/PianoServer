json.parties @parties do |party|
  json.extract! party, *(party.attribute_names + ["withdrawable"] - ["person_avatar"])
  json.bless_count party.blesses.count
  json.heart_count party.blesses.free_hearts.paid.count
  json.gnh party.vv

  if party[:person_avatar].present?
    json.person_avatar party.person_avatar.try(:url, :cover)
  else
    json.person_avatar nil
  end
end
