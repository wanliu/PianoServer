FactoryGirl.define do
  factory :shop do
    association :owner, factory: :user 
    industry
    location

    description "description"

    sequence(:address) { |n| "shop_address_#{n}" }
    sequence(:name) { |n| "shop_name_#{n}" }
    sequence(:title) { |n| "shop_title_#{n}" }
    sequence(:phone) { |n| 19211111111 + n }
  end

end
