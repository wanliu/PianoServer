json.parties @parties do |party|
  json.extract! party, *(party.attribute_names + ["withdrawable"] - ["person_avatar"])
  json.bless_count party.bc
  json.heart_count party.fc
  json.gnh 10*party.vv

  if party[:person_avatar].present?
    json.person_avatar party.person_avatar.try(:url, :cover)
  else
    json.person_avatar nil
  end
end
