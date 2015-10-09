require 'content_management/subject/file_system'
require 'rails/generators'

module ShopService
  extend self

  def build(name)
    Rails::Generators.invoke 'shop:build', [ name, "--skip" ]
  end

  def valid?(shop)
    shop.shop_category.present?
  end

  def root
    File.join(Rails.root, Settings.sites.shops.root)
  end

  def shop_path(shop)
    File.join(root, shop.name)
  end

  def template_path(shop, filename)
    File.join(shop_path(shop), "views", filename)
  end

  def views_path(shop)
    File.join(shop_path(shop), "views")
  end

  def set_file_system(shop)
    Liquid::Template.file_system = ContentManagement::FileSystem.new(views_path(shop), "_%s.html.liquid".freeze)
  end

  private

  def logger
    Rails.logger
  end

  def builtin_category(shop)
    @main_menu_cate = shop.shop_category || shop.create_shop_category(attributes)
  end

end
