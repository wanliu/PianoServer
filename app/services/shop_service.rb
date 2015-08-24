require 'rails/generators'

module ShopService
  extend self

  def build(name)
    Rails::Generators.invoke 'shop:build', [ name ]
  end

  def valid?(shop)
    shop.categories.find_by(name: 'product_category').present?
  end

  private

  def builtin_category(shop)
    @main_menu_cate = shops.categories.where(type: 'shop_built-in', name: 'main-menu').first_or_initialize_by
  end
end
