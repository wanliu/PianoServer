FactoryGirl.define do
  factory :order do
    association :buyer, factory: :user
    association :supplier, factory: :shop

    total 100
    delivery_address "some address"
    total_modified false
    receiver_name "user name"
    receiver_phone "12345678912"

    before(:create) do |order|
      4.times do
        order.items << FactoryGirl.create(:order_item, order: order)
      end
    end
  end
end
