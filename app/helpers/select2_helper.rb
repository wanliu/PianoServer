module Select2Helper

  def select2(object_name, method, choices = nil, options = {}, html_options = {}, &block)
    obj_id = caller.object_id

    _html_options = {
      "select2-id" => obj_id
    }

    select2_options = options.delete(:select2) || {}

    html = <<-HTML
      #{select object_name, method, choices, options, html_options.merge(_html_options), &block}
      <script type="text/javascript">
        var options = #{select2_options.to_json};
        $('[select2-id="#{obj_id}"]').select2($.extend({}, options, {
          theme: "bootstrap"
        }));
      </script>
    HTML
    html.html_safe
  end

  def select2_url(object_name, method, url, choices = nil, options = {}, html_options = {}, &block)
    obj_id = caller.object_id

    _html_options = {
      "select2-id" => obj_id
    }

    html = <<-HTML
      #{select object_name, method, choices, options, html_options.merge(_html_options), &block}
      <script type="text/javascript">

        $('[select2-id="#{obj_id}"]').select2({
            theme: "bootstrap",
            placeholder: '选择',
            ajax: {
              url: "#{url}"
            }
        }).on('change', function(e) {
          data = $(this).select2('data')[0];

          $.ajax({
            url: "#{url}/" + data.id,
            type: 'PATCH'
          });
        });
      </script>
    HTML
    html.html_safe
  end

  def select2_url_template(object_name, method, url, choices = nil, options = {}, html_options = {}, &block)
    obj_id = caller.object_id

    _html_options = {
      "select2-id" => obj_id
    }

    select2_options = {
      placeholder: '选择'
    }

    select2_options[:placeholder] = options[:placeholder] if options[:placeholder].present?

    html = <<-HTML
      #{select object_name, method, choices, options, html_options.merge(_html_options), &block}
      <script type="text/javascript">
        var _tpl = _.template("#{j options[:template]}");

        function formatState(state) {
          if (!state.id) { return state.text; }
          return $(_tpl(state));
        }

        $('[select2-id="#{obj_id}"]').select2($.extend({
            theme: "bootstrap",
            ajax: {
              url: "#{url}"
            },
            templateResult: formatState
        }, #{select2_options.to_json})).on('change', function(e) {
          data = $(this).select2('data')[0];

          $.ajax({
            url: "#{url}/" + data.id,
            type: 'PATCH'
          });
        });
      </script>
    HTML
    html.html_safe
  end

  def select2_tags(object_name, method, choices = nil, options = {}, html_options = {}, &block)
    obj_id = caller.object_id

    _html_options = {
      "select2-id" => obj_id,
      multiple: true
    }

    # options = options.merge multiple: true
    tags = options.delete(:tags) || true

    html = <<-HTML
      #{select object_name, method, choices, options, html_options.merge(_html_options)}
      <script type="text/javascript">
        var options = {}
        $('[select2-id="#{obj_id}"]').select2($.extend({}, options, {
          tags: #{tags.to_json},
          theme: "bootstrap"
        }));
      </script>
    HTML
    html.html_safe
  end
end
