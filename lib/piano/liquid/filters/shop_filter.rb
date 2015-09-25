module Piano
  module Liquid
    module Filters
      def shop_link(name, shop, url, options ={})
        @context.registers[:view].link_to(name, shop.link + url.to_s, options)
      end
    end
  end
end

Liquid::Template.register_filter(Piano::Liquid::Filters)
