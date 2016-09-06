json.array!(@temp_birthday_parties) do |temp_birthday_party|
  json.extract! temp_birthday_party, :id, :cake_id, :quantity, :birth_day, :delivery_time, :user_id, :sales_man_id, :message, :delivery_address, :birthday_person, :person_avatar
  json.url temp_birthday_party_url(temp_birthday_party, format: :json)
end
