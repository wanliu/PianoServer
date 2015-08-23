module ShopsHelper
  def shop_render(template, *args)
    template += '.liquid' if File.extname(template) != '.liquid'

    path = File.join(@shop.name, "views", template).to_s

    render partial: path
  end
end
