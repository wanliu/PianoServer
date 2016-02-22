FactoryGirl.define do
  province_id = ChinaCity.list.first.second
  city_id = ChinaCity.list(province_id).first.second
  region_id = ChinaCity.list(city_id).first.second

  factory :location do
    province_id province_id 
    city_id city_id
    region_id region_id

    sequence(:contact) { |n| "location_contact_name#{n}" }
    sequence(:contact_phone) { |n| 17711111111 + n }
    sequence(:road) { |n| "location_road_#{n}" }
  end
end
