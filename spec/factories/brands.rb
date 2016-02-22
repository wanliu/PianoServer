FactoryGirl.define do
  factory :brand do
     sequence(:name) { |n| "brand_name_#{n}" }
  end
end
