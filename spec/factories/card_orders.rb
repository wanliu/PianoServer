FactoryGirl.define do
  factory :card_order do
    wx_card_id "MyString"
    paid false
    withdrew false
    pmo_grab_id 1
    one_money_id 1
    item nil
  end
end
