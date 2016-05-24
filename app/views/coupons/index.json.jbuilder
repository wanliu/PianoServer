json.array!(@coupons) do |coupon|
  json.extract! coupon, :id, :coupon_template_id, :receiver_shop_id, :receiv_time, :receive_taget_id, :receive_taget_type, :customer_id, :start_time, :end_time, :status
  json.url coupon_url(coupon, format: :json)
end
