module Piano
  module LiquidTags
    class TitleChain < ::Liquid::Tag
      include ShopsHelper

      Syntax = /(#{::Liquid::QuotedFragment})\s+(#{::Liquid::QuotedFragment})/

      def initialize(tag_name, markup, tokens)
        if markup =~ Syntax
          @shop = $1
          @shop_category = $2
        else
          raise SyntaxError.new("Syntax Error in tag 'title_chain' - Valid syntax: navbar shop_variable, shop_category_variable")
        end
        super
      end

      def render(context)
        shop = context[@shop].send(:object)
        shop_category = context[@shop_category].send(:object)

        title_chain_render(shop, shop_category)
      end
    end
  end
end

Liquid::Template.register_tag('title_chain', Piano::LiquidTags::TitleChain)
