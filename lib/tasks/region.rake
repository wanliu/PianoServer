namespace :region do
  desc "generate all china city region."
  task :generate => :environment do |task, args|
    region = Region.where(name: "China").first_or_create(name: "China", title: "中华人民共和国")

    create_region(region)
  end
end

def create_region(region, list = ChinaCity.list, depth = 3, &block)
  return if depth == 0

  list.each do |title, id|
    name = Pinyin.t(title, splitter: '')

    child = region.children.create name: name, title: title, city_id: id
    yield child if block_given?
    create_region(child, ChinaCity.list(id), depth - 1)
  end
end
