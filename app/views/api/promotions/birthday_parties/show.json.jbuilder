props_title = nil
title = nil
cake_price = nil

if @birthday_party.order_id.present?
  order = @birthday_party.order
  order_item = order.items.first
  title = order_item.title
  props_title = order_item.properties_title
  cake_price = order_item.price
elsif @birthday_party.cake.present?
  item = @birthday_party.cake.item
  title = item.title
  props_title = @birthday_party.properties_title
  cake_price = item.price
end

json.extract! @birthday_party, *(@birthday_party.attribute_names - ["person_avatar"])
json.withdraw_url WeixinApi.get_openid_url(withdraw_birthday_party_path(@birthday_party))
json.gnh 10 * @birthday_party.all_blesses_value
json.hearts_count @hearts_count
json.progress @progress
json.cake_title "#{title} #{props_title}"
json.cake_price cake_price

if @birthday_party[:person_avatar].present?
  json.person_avatar @birthday_party.person_avatar.try(:url, :cover)
else
  json.person_avatar nil
end
