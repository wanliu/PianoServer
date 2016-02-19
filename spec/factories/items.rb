FactoryGirl.define do
  factory :item do
    shop
    category
    brand

    association :shop_category, factory: :shop_category#, shop: shop

    sequence(:price, 20) { |n| n }
    sequence(:inventory, 30) { |n| n }
    sequence(:sid, 1) { |n| n }
    sequence(:title) { |n| "item_title_#{n}" }
    sequence(:public_price, 20) { |n| n }
    sequence(:income_price, 20) { |n| n }

    properties "{}"
    description "description"

    after(:create) do |item|
      item.build_stocks(item.shop.owner, rand(1000))
      item.save
    end
  end
end