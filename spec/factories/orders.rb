FactoryGirl.define do
  factory :order do
    buyer
    supplier
    total 100
    delivery_address "some address"
    total_modified false
    receiver_name "user name"
    receiver_phone "12345678912"
  end
end
