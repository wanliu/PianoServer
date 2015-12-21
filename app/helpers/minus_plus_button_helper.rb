module MinusPlusButtonHelper

  def minus_plus_button_field(object_name, method_name, options = {}, &block)
    obj_id = caller.object_id

    options_class = options.delete(:class)
    options_class = options_class.is_a?(Array) ? options_class : [ options_class ]

    default_options = {
      class: [ 'minus_plus_input' ] + options_class
    }

    html = <<-HTML
      <div class="form-group minus-group">
        <div class="media sale-options-media">
          <div class="media-left">
            <div class="input-group minus-plus-button" minus-plus-button-id="#{obj_id}" >
              <span class="input-group-btn">
                #{link_to '#minus', class: 'btn btn-default btn-minus' do
                  s('<b>') + s(icon(:minus)) + s('</b>')
                end}
              </span>
                #{text_field object_name, method_name, options.merge(default_options)}
              <span class="input-group-btn">
                #{link_to '#plus', class: 'btn btn-default btn-plus' do
                  s('<b>') + s(icon(:plus)) + s('</b>')
                end}
              </span>
            </div>
          </div>
        </div>
      </div>
      <script type="text/javascript">
        (function() {
          var $input_field = $("[minus-plus-button-id=#{obj_id}]");
          var max_number = #{options[:max] || 9999}

          $input_field.find(".btn-minus").click(function(e) {
            e.preventDefault();
            number = parseInt($input_field.find(".minus_plus_input").val()) || 1
            if (number > 1) {
              var $number_field = $input_field.find(".minus_plus_input");
              var new_number = number - 1;

              $number_field.val(new_number);
              $number_field.trigger('change', new_number);
            }
          });

          $input_field.find(".btn-plus").click(function(e) {
            e.preventDefault();

            number = parseInt($input_field.find(".minus_plus_input").val()) || 1
            if (number < max_number) {
              var $number_field = $input_field.find(".minus_plus_input");
              var new_number = number + 1;

              $number_field.val(new_number);
              $number_field.trigger('change', new_number);
            }
          });
        })();
      </script>
    HTML
    html.html_safe
  end
end
