module Piano
  module LiquidTags
    Syntax = /(#{::Liquid::QuotedFragment})(.*)/
    AttributesSyntax = /\s*(#{::Liquid::TagAttributes})/
    Inspect = /(["'])(.*)\k<1>/

    class NavbarTag < ::Liquid::Tag

      def initialize(tag_name, markup, tokens)
        if markup =~ Syntax
          @variable = $1
          @styles = parse_attributes($2) || {}
        else
          raise SyntaxError.new("Syntax Error in tag 'navbar_tags' - Valid syntax:navbar variable [attrib:name, ...]")
        end
        super
      end

      def render(context)
        variable = context[@variable]

        raise ::Liquid::ArgumentError.new("Cannot variable '#{@variable}'. Not found.") if variable.nil?

        @styles["background-color"] || = "transparent"
        @styles["color"] ||= "#333333"
        @styles["text_shadow"] ||= "none"

        <<-HTML
        <style type="text/css">
          .navbar {
            background-color: #{@styles["background-color"]};
            color: #{@styles["color"]};
            text-shadow: #{@styles["text_shadow"]}
          }
        </style>

        <script type="text/javascript">
          $(document).scroll(function() {
            var $this = $(this),
                scrollTop = $this.scrollTop(),
                $nav = $('.navbar-fixed-top'),
                prevScrollTop = $this.data('scroll_top') || 0,
                opacity;

            if (scrollTop < 100) {
              var _opacity = $nav.css('opacity');
              opacity = +_opacity * 100 - (scrollTop - prevScrollTop) * 10 / 100;
              $this.data('scroll_top', scrollTop);
            } else {
              opacity = scrollTop === 0 ? 100 : 90;
              $this.data('scroll_top', opacity);
            }

            $nav.css('opacity', opacity / 100);
          });

        </script>
        HTML
      end

      private

      def parse_attributes(string)
        Hash[string.scan(AttributesSyntax).map {|_, key, value| [key, value]}]
      end
    end
  end
end

Liquid::Template.register_tag('navbar', Piano::LiquidTags::NavbarTag)
