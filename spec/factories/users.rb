FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "username_#{n}" }
    sequence(:email) { |n| "user_email_#{n}@mail.com" }
    password '12345678'
    sequence(:mobile) { |n| 13311111111 + n }
  end
end