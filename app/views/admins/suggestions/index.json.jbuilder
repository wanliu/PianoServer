json.array!(@suggestions) do |suggestion|
  json.extract! suggestion, :id, :title, :count, :check
  json.url suggestion_url(suggestion, format: :json)
end
