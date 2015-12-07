module Select2Helper

  def select2(object_name, method, choices = nil, options = {}, html_options = {}, &block)
    obj_id = caller.object_id

    _html_options = {
      "select2-id" => obj_id
    }

    html = <<-HTML
      #{select object_name, method, choices, options, html_options.merge(_html_options), &block}
      <script type="text/javascript">

        $('[select2-id="#{obj_id}"]').select2({
            theme: "bootstrap"
        });
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
end
