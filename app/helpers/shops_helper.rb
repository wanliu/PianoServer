module ShopsHelper
  def shop_render(template, *args)
    template += '.liquid' if File.extname(template) != '.liquid'

    path = File.join(@shop.name, "views", template).to_s

    render partial: path
  end

  def title_chain_render(shop, shop_category)
    html = shop_category.self_and_ancestors.map do |cate|
      <<-HTML
        <a href="#{shop_shop_category_path(shop.name, cate)}">#{cate.title}</a>
      HTML
    end.join("<span class='glyphicon glyphicon-menu-right' aria-hidden='true'></span>")

    sanitize html
  end
end
