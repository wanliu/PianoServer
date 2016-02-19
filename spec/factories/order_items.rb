FactoryGirl.define do
  factory :order_item do
    order nil
    association :orderable, factory: :item
    title "MyString"
    price "9.99"
    quantity 1
    data ""
    properties ""
  end
end