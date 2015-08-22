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
    copy_file 'views/index.html.erb', "#{shop_path}/views/index.html.erb"

    create_category name: 'product_category', title: '商品分类', category_type: 'builtin'
  end

  protected

  def create_category(attributes = {})
    category = shop
      .categories
      .find_or_initialize_by(attributes)

    if category.persisted?
      say_status :exist, "Category #{attributes}", :blue
    else
      shop.categories << category
      say_status :create, "Category #{attributes}"
    end
  end

  def shop
    @shop ||= Shop.find_by(name: file_name)
  end

  def shop_root
    options[:shop_root] || Settings.sites.root
  end

  def shop_path
    File.join(shop_root, file_name)
  end
end
