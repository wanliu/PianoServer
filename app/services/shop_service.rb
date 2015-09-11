require 'rails/generators'

module ShopService
  extend self

  def build(name)
    Rails::Generators.invoke 'shop:build', [ name ]
  end

  def valid?(shop)
    shop.shop_category.present?
  end

  private

  def builtin_category(shop)
    @main_menu_cate = shop.shop_category || shop.create_shop_category(attributes)
  end
end
