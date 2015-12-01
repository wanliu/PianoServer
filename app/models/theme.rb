class Theme
  include ContentManagement::Model

  def initialize(shop)
    @shop = shop
    @name = shop.theme
  end

  def instance_name
    if @name.blank?
      @shop.name 
    else
      File.join(@shop.name, "theme_#{@name}")
    end
  end

  def content_root
    File.join Rails.root, Settings.sites.root, @shop.class.name.tableize
  end
end