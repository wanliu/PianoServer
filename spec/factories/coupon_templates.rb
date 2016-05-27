FactoryGirl.define do
  factory :coupon_template do
    issuer_id nil
    issuer_type nil
    sequence(:name) {|n| "Coupon #{n}" }
    par 9.99
    apply_items 1
    apply_minimal_total 9.99
    apply_shops 1
    apply_time 1
    overlap false
  end
end
