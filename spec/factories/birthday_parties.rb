FactoryGirl.define do
  factory :birthday_party do
    cake
    order
    user
    message "ddd"
    hearts_limit ""
    birth_day "2016-06-17"
    birthday_person "MyString"
    person_avatar "MyString"
  end
end
