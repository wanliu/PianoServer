if params[:inline]
  json.(@intention, *@intention.attributes.keys)
  json.html render partial: "chats/chat_order_table", object: @intention, formats: [ :html ]
else
  json.(@intention, *@intention.attributes.keys)
end
