module Piano
  module Liquid
    module Filters
      def shop_link(url, shop)
        shop.link + url.to_s
      end

      def shop_link_to(name, shop, url, options = {})
        @context.registers[:view].link_to(name, shop_link(url, shop), options)
      end

      def button_to_chat(name, item, shop, html_options = {})
        @context.registers[:view].button_to(name, @context.registers[:view].item_chats_path(item.id, shop_id: shop.id), html_options)
      end

      def button_to(name, options, html_options = {})
        @context.registers[:view].button_to(name, options, html_options)
      end
    end
  end
end

Liquid::Template.register_filter(Piano::Liquid::Filters)
