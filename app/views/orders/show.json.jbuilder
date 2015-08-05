if params[:inline]
  json.(@order, *@order.attributes.keys)
  json.html render partial: "chats/chat_order_table", object: @order, formats: [ :html ]
else
  json.(@order, *@order.attributes.keys)
end
