FactoryGirl.define do
  factory :coupon_token do
    coupon_template nil
customer nil
token "MyString"
version_lock 1
  end

end
