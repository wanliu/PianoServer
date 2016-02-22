FactoryGirl.define do
  factory :shop_category do
    shop

    sequence(:name) { |n| "shop_category_#{n}" }
  end
end