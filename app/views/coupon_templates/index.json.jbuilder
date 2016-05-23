json.array!(@coupon_templates) do |coupon_template|
  json.extract! coupon_template, :id, :issuer_id, :issuer_type, :name, :par, :appliy_items, :apply_minimal_total, :apply_shops, :apply_time, :overlop
  json.url coupon_template_url(coupon_template, format: :json)
end
