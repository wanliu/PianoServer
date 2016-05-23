FactoryGirl.define do
  factory :coupon_template do
    issuer nil
name "MyString"
par "9.99"
appliy_items 1
apply_minimal_total "9.99"
apply_shops 1
apply_time 1
overlop false
  end

end
