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

    description "description"

    before(:create) do |item|
      item.build_stocks(item.shop.owner, rand(1000))
    end

    # FactoryGirl/Rspec dont call after_commit callbacks before Rails 5,
    # this is a hot fix, remove this hook if updated to Rails 5
    after(:create) do |item|
      item.update_current_stock!
    end
  end
end