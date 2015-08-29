module Liquid
  module Rails
    Syntax = /(#{::Liquid::QuotedFragment})(.*)/
    AttributesSyntax = /\s*(#{::Liquid::TagAttributes})/
    Inspect = /(["'])(.*)\k<1>/

    class BackgroundTags < ::Liquid::Tag

      def initialize(tag_name, markup, tokens)
        if markup =~ Syntax
          @variable = $1
          @styles = parse_attributes($2) || {}
        else
          raise SyntaxError.new("Syntax Error in tag 'background_image' - Valid syntax: background_image  variable [attrib:name, ...]")
        end
        super
      end

      def render(context)
        variable = context[@variable]
        raise ::Liquid::ArgumentError.new("Cannot variable '#{@variable}'. Not found.") if variable.nil?
        styles = @styles.slice("repeat", "position", "origin", "size")

        background_styles = styles.map do |sty, val|
          val = $2 if val =~ Inspect
          "background-#{sty}: #{val};"
        end.join('\n')

        <<-HTML
        <style type="text/css">
          body {
            background-image: url(#{variable});
            #{background_styles}
          }
        </style>
        HTML
      end

      private

      def parse_attributes(string)
        Hash[string.scan(AttributesSyntax).map {|_, key, value| [key, value]}]
      end
    end
  end
end

Liquid::Template.register_tag('background_image', Liquid::Rails::BackgroundTags)
