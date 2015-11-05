module Admins::VariableHelper

  def variables_path(subject, host, *args)
    admins_subject_template_variables_path(subject, host, *args)
  end
end
