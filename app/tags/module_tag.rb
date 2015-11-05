module Piano
  module LiquidTags
    class ModuleTag < ::Liquid::Tag
      Syntax = /(#{::Liquid::QuotedFragment}+)/

      def initialize(tag_name, markup, tokens)
        if markup =~ Syntax
          @variable = $1
        else
          raise SyntaxError.new("Syntax Error in tag 'module' - Valid syntax: module \"module_name\"")
        end
        super
      end

      def render(context)
        context.registers[:view].content_for(:module, @variable)
      end

      private

      def parse_attributes(string)
        Hash[string.scan(AttributesSyntax).map {|_, key, value| [key, value]}]
      end
    end
  end
end

Liquid::Template.register_tag('module', Piano::LiquidTags::ModuleTag)
