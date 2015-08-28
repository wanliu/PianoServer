module Admins::SubjectHelper

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

  def modal_target(config)
    # '#' + config[:class].name.underscore
    '#variable_editor_modal'
  end

  def title_extract(template)
    if template.name.present? && Template::RESERVED_NAMES.include?(template.name)
      template.name
    else
      sanitize "<input autofocus='autofocus' class='form-control template-filename' placeholder='请输入文件名称' type='text' name='template[filename]' id='template_filename' value='#{template.filename}'>"
    end
  end
end
