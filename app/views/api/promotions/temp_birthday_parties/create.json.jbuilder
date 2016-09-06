json.extract! @temp_birthday_party, *(@temp_birthday_party.attribute_names - ["active_token", "person_avatar", "active_token_qrcode"])
json.active_token_qrcode @temp_birthday_party.active_token_qrcode.url
json.person_avatar @temp_birthday_party.birthday_party.try(:person_avatar).try(:url)
json.is_sales_man @is_sales_man

json.order_item do
  json.title "#{@temp_birthday_party.order_item.title} #{@temp_birthday_party.order_item.properties_title}"
  json.price @temp_birthday_party.order_item.price
  json.quantity @temp_birthday_party.order_item.quantity
  json.images @temp_birthday_party.order_item.orderable.images
end
