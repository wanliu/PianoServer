password = '12345678'
mobile = 12345678911

owner = User.create!(username: 'owner', password: password, email: 'owner@mail.com', mobile: mobile += 1)

admin = Admin.create(email: 'admin@126.com', password: '12345678')

province_id = ChinaCity.list[0][1]
city_id = ChinaCity.list(province_id)[0][1]
region_id = ChinaCity.list(city_id)[0][1]

location = Location.create!(province_id: province_id,
  city_id: city_id,
  region_id: region_id,
  contact: 'shopowner',
  contact_phone: mobile += 1,
  road: 'some road')

shop = Shop.create!(name: 'shop_test',
  title: 'shop_test', 
  phone: mobile += 1, 
  location: location, 
  owner: owner,
  address: 'some place you will never find:)',
  description: 'dont buy anything we sales, or you will be regret about it')

shop_category = shop.create_shop_category(name: 'root')

%w(milk cloth viduo computer books).each do |cate|
  shop_category.children.create(name: cate)
end

(1..100).each do |id|
  User.create!(username: "user#{id}", password: password, email: "user#{id}@mail.com", mobile: mobile += 1)
end

Rake::Task['db:sync_brands'].invoke

cate_root = Category.create(name: 'cate_root')
level_1 = cate_root.children.create(name: 'cate_level_1')
level_2 = level_1.children.create(name: 'cate_level_2')
level_3 = level_2.children.create(name: 'cate_level_3')

(1..20).each do |id|
  item = shop.items.build(title: "item#{id}",
    brand: Brand.first,
    price: 50 + id,
    public_price: 80 + id,
    income_price: 30 + id,
    shop_category: shop_category.children.last,
    description: "description",
    category: level_3,
    sid: id)

  item.build_stocks(owner, 100)

  item.save!
end