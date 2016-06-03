json.array!(@express_templates) do |express_template|
  json.extract! express_template, :id, :shop_id, :name, :template
  json.url express_template_url(express_template, format: :json)
end
