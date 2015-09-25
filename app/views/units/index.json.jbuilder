json.array! @units do |unit|
  json.(unit, :id, :title, :name, :summary)
end