FactoryGirl.define do
  factory :cart_item do
    cart
    association :cartable, factory: :item
    association :supplier, factory: :shop
    price 88
    quantity 1
    properties {} 
  end
end
