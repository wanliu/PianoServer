if query_params[:inline]
  json.(promotion, :id, :title)
  json.html render partial: "promotion_item", object: promotion, formats: [ :html ]
else
  json.(promotion, *promotion.attributes.keys)
end
