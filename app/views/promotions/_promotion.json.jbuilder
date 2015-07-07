if @query_params[:inline] 
  json.(promotion, :id)
  json.html render partial: "promotion", object: promotion, formats: [ :html ]
else
  json.(promotion, *promotion.attributes.keys)
end

