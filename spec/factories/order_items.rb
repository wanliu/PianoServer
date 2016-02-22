FactoryGirl.define do
  factory :order_item do
    order
    association :orderable, factory: :item#, shop: order.supplier
    title "MyString"
    price "9.99"
    quantity 1
    data ""
    properties ""
  end
end