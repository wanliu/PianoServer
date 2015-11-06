module Admins::SubjectHelper

  # default_options :form_for, {
  #   layout: :inline
  # }

  # extend_helper :form_for, :template, default_options: {
  #   layout: :inline,
  #   remote: true,
  #   html: {
  #     class: (template) -> { "#{prefix}#{template.id}" }
  #   }
  # }

  # extend_helper :panel, :main, {
  #   id: (template) -> { "edit-template-#{template.id}" },
  #   class: %w(tab-pane fade in edit-template active)
  # }

  def new_variable_path(subject, template, type_or_class)
    type = case type_or_class
           when Symbol, String
             type_or_class
           else
             if type_or_class < Variable
               type_or_class.name.underscore
             else
               throw ArgumentError.new('type_or_class must a Symbol, String or Variable')
             end
           end

    path = admins_subject_template_variables_path(subject, template)
    File.join(path, "new_#{type}")
  end

  def template_edit_path(subject, template)
    [:admins, subject, :template, {id: template.filename }]
  end

  def modal_target(config)
    # '#' + config[:class].name.underscore
    '#variable_editor_modal'
  end

  def title_extract(template)
    if template.reserved?
      template.name
    else
      sanitize "<input autofocus='autofocus' class='form-control template-filename' placeholder='请输入文件名称' type='text' name='template[filename]' id='template_filename' value='#{template.filename}'>"
    end
  end

  def template_object(object)
    [ :admins, @subject, object.becomes(::Template) ]
  end

  def link_to_variable(config, *args, &block)
    options = args.extract_options!

    default_options = {
      data: {
        class: config[:name],
        op: 'new'
      }
    }

    link_to_modal modal_target(config), config[:title], '#', options.deep_merge(default_options), &block
  end

  def form_for_template(template, options = {}, &block)
    prefix = options[:form_prefix] || "template-form-"

    default_options = {
      layout: :inline,
      remote: true,
      builder: ::TemplateBuilder,
      html: {
        class: "#{prefix}#{template.id}"
      }
    }

    form_for template_object(template), options.merge(default_options), &block
  end

  def panel_main(template, *args, &block)
    options = args.extract_options!
    default_options = { id: "edit-template-#{template.id}", class: "tab-pane fade in edit-template active" }

    panel options.merge(default_options), &block
  end

  def dropdown_add_variable(template)
    dropdown '新增对象'

  end
end
