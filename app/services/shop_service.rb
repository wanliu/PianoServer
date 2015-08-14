module ShopService
  extend self

  def create(name, template, attributes = {})
    # Shop.create()
  end

  def migrate(name)
    @shop = Shop.find_by name: name
    builtin_category(@shop)
  end

  private

  def builtin_category(shop)
    @main_menu_cate = shops.categories.where(type: 'shop_built-in', name: 'main-menu').first_or_initialize_by
  end
end
