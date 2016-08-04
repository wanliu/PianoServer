FactoryGirl.define do
  factory :virtual_present do
    price "9.99"
    sequence(:name) { |n| "heart" }
    sequence(:title) { |n| "virtual_present_title_#{n}" }
  end
end
