json.extract! @birthday_party, *(@birthday_party.attribute_names + ["withdrawable",  "rank_position"] - ["person_avatar"])
json.withdraw_url WeixinApi.get_openid_url(withdraw_birthday_party_path(@birthday_party))
json.withdrawable @birthday_party.withdrawable
if @birthday_party[:person_avatar].present?
  json.person_avatar @birthday_party.person_avatar.try(:url, :cover)
else
  json.person_avatar nil
end
