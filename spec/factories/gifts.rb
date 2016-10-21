FactoryGirl.define do
  factory :gift do
    item
    association :present, factory: :item
    quantity 1
    total 100
  end
end
