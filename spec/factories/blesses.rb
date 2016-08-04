FactoryGirl.define do
  factory :bless do
    association :sender, factory: :user
    virtual_present nil
    message "MyText"
    birthday_party nil
  end
end
