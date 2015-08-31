module Piano
  module LiquidTags
    AttributesSyntax = /\s*(#{::Liquid::TagAttributes})/

    class NavbarTag < ::Liquid::Tag

      def initialize(tag_name, markup, tokens)
        pp markup =~ AttributesSyntax

        if markup =~ AttributesSyntax
          @styles = parse_attributes(markup) || {}
        else
          raise SyntaxError.new("Syntax Error in tag 'navbar_tag' - Valid syntax: navbar [attrib:name, ...]")
        end
        super
      end

      def render(context)
        @styles["background-color"] ||= "transparent"
        @styles["color"] ||= "#333333"
        @styles["text_shadow"] ||= "none"

        <<-HTML
        <style type="text/css">
          .navbar-fixed-top {
            background-color: #{@styles["background-color"]};
            text-shadow: #{@styles["text_shadow"]};
          }

          .navbar-fixed-top .navbar-nav > li > a {
            color: #{@styles["color"]};
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
