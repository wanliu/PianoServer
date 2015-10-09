if @query_params[:inline]
  json.(promotion, :id)
  json.html render partial: "promotion_line", object: promotion, formats: [ :html ]
else
  json.(promotion, *promotion.attributes.keys)
end

