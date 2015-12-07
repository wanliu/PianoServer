module ShopsHelper
  # def shop_render(template, *args)
  #   template += '.liquid' if File.extname(template) != '.liquid'

  #   path = File.join(@shop.name, "views", template).to_s

  #   render partial: path
  # end

  def exists?(template)
    template = template.to_s
    dir, base = File.dirname(template), File.basename(template)
    tmp_file = File.join(ShopService.shop_path(@shop), "views", File.join(dir, "_#{base}.html.liquid"))
    File.exists? tmp_file
  end

  def shop_render(template, *args)
    options = args.extract_options!

    if options[:partial] && @shop.nil?
      render options
    elsif @shop.nil?
      return
    else
      if exists? template
        ShopService.set_file_system @shop
        path = File.join(@shop.name, "views", template.to_s).to_s
        render({partial: path }.reverse_merge(options))
      else
        render({ partial: template.to_s }.reverse_merge(options))
      end
    end
  end

  def title_chain_render(shop, shop_category)
    html = shop_category.self_and_ancestors.map do |cate|
      <<-HTML
        <a href="/#{shop.name}/categories/#{cate.id}.html">#{cate.title}</a>
      HTML
    end.join("<span class='glyphicon glyphicon-menu-right' aria-hidden='true'></span>")

    html.html_safe
  end

  def shop_header_style(shop)
    background_url = shop.settings["head_url"] || asset_url(Settings.shop.default_head_url)
    light_png = asset_url("light.png")
    css = <<-CSS
      background: url(#{background_url});
      background: url(#{light_png}) 50%, -moz-linear-gradient(top,  rgba(0,0,0,0) 0%, rgba(0,0,0,0.65) 100%), /* FF3.6-15 */ url(#{background_url});
      background: url(#{light_png}) 50%,-webkit-linear-gradient(top,  rgba(0,0,0,0) 0%,rgba(0,0,0,0.65) 100%), /* Chrome10-25,Safari5.1-6 */ url(#{background_url});
      background: url(#{light_png}) 50%, linear-gradient(to bottom,  rgba(0,0,0,0) 0%,rgba(0,0,0,0.65) 100%), url(#{background_url});
      filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#00000000', endColorstr='#a6000000',GradientType=0 ); /* IE6-9 */

      height: 100px;
      background-size: 100%;
      background-position: 50%;
    CSS
  end
end
