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
    default_options = {
      'ace-editor-id': obj_id
    }

    scripts = <<-JAVASCRIPT
      var element = $('[ace-editor-id="#{obj_id}"]')[0];
      var editor = ace.edit(element);
      editor.setTheme('ace/theme/#{theme}');
      editor.getSession().setMode('ace/mode/#{mode}');
    JAVASCRIPT


    content_tag(:div, object.send(attribute) || '', options.deep_merge(default_options)) +
    javascript_tag(scripts)
  end
end
