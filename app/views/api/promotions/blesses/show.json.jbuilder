json.extract! @bless, *@bless.attribute_names
json.sender @bless.sender, :id, :avatar_url, :nickname
json.virtual_present @bless.virtual_present_infor
unless @bless.paid?
  json.wx_pay_url WeixinApi.get_openid_url(wxpay_blesses_path(@bless))
end
