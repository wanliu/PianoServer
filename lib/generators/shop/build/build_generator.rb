class Shop::BuildGenerator < Rails::Generators::NamedBase
  desc "This generator build shop files at app/shops"

  source_root File.expand_path('../templates', __FILE__)

  class_option :shop_root, type: :string

  def initialize(*args)
    super

    unless shop
      raise Rails::Generators::Error.new("Invalid shop name `#{file_name}`, Build a shop website before it created")
    end
  end

  def copy_shop_files
    copy_file 'views/_about.html.liquid', "#{shop_path}/views/_about.html.liquid"
    copy_file 'views/_index.html.liquid', "#{shop_path}/views/_index.html.liquid"
    copy_file "views/_header.html.liquid", "#{shop_path}/views/_header.html.liquid"
    copy_file "views/_category.html.liquid", "#{shop_path}/views/_category.html.liquid"
    copy_file "views/_item.html.liquid", "#{shop_path}/views/_item.html.liquid"
    copy_file "views/_shop_category_list.html.liquid", "#{shop_path}/views/_shop_category_list.html.liquid"
    copy_file "views/items/_show.html.liquid", "#{shop_path}/views/items/_show.html.liquid"

    create_shop_category name: 'product_category', title: '商品分类', category_type: 'builtin'
  end

  protected

  def create_shop_category(attributes = {})
    shop_category = shop.shop_category || shop.create_shop_category(attributes)

    if shop_category.persisted?
      say_status :exist, "Category #{attributes}", :blue
    else
      say_status :create, "Category #{attributes}"
    end
  end

  def shop
    @shop ||= Shop.find_by(name: file_name)
  end

  def shop_root
    options[:shop_root] || Settings.sites.shops.root
  end

  def shop_path
    File.join(shop_root, file_name)
  end
end
