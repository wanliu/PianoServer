module AceEditorHelper

  # Ace Editor ActionView helper
  # @param object ActiveRecord::Base Model object
  # @param attribute String, Symbol A Model Attribute Name, To get file content
  # @param filename String The filename
  # @param options ={} Hash Options
  # @option theme String, Symbol options[:theme] ('twilight') set editor theme styles
  # @option mode String,Symbol options[:mode] ('liquid') The file type, syntax highlight styles
  #
  # @return String Ace Editor Html
  def ace_editor(object, attribute, filename, options ={})
    obj_id = caller.object_id

    theme = options.delete(:theme) || 'twilight'
    mode = options.delete(:mode) || 'liquid'
    save_button = options[:save_button]

    bind = options.delete(:save_button)
    bind_options = bind && bind.to_options

    url = options[:url]
    url = url_for(object) unless url
    http_options = options.slice(:method, :data_type)
    data_options = { template: { filename: filename, name: object.name } }
    http_options.merge!(url: url, method: :patch, data: data_options )
    http_options[:method] = :post unless object.persisted?


    default_options = {
      'ace-editor-id': obj_id
    }.merge(bind_options)

    scripts = <<-JAVASCRIPT
      var element = $('[ace-editor-id="#{obj_id}"]')[0];
      var editor = ace.edit(element);
      var http_options = #{http_options.to_json};

      editor.setTheme('ace/theme/#{theme}');
      editor.getSession().setMode('ace/mode/#{mode}');

      $(function() {
        $("#{bind.to_jquery(:to)}").on('#{bind.event}', function(e) {
          e.preventDefault();

          http_options['data']['template']['content'] = editor.getValue();

          $.ajax(http_options).success(function() {

          });
        })
      });
    JAVASCRIPT


    content_tag(:div, object.send(attribute) || '', options.deep_merge(default_options)) +
    javascript_tag(scripts)
  end
end
