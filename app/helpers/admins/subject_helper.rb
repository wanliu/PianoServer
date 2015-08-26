module Admins::SubjectHelper

  def new_variable_path(subject, template, *args)
    new_admins_subject_template_variable_path(subject, template, *args)
  end

  def modal_target(config)
    '#' + config[:class].name.underscore
  end
end
