module Piano
  module Liquid
    module Filters
      def shop_link(url, shop)
        shop.link + url.to_s
      end

      def shop_link_to(name, shop, url, options = {})
        @context.registers[:view].link_to(name, shop_link(url, shop), options)
      end
    end
  end
end

Liquid::Template.register_filter(Piano::Liquid::Filters)
