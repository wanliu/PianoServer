module Admins::VariableHelper

  def variables_path(subject, template, *args)
    admins_subject_template_variables_path(subject, template, *args)
  end
end
