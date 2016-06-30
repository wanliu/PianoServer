json.extract! @birthday_party, *(@birthday_party.attribute_names.concat(["withdrawable"]))
json.wx_pay_url WeixinApi.get_openid_url(withdraw_birthday_party_path(@birthday_party))
