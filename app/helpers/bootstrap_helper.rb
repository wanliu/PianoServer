module BootstrapHelper

  def bootstrap_flash
    flash_class = {
      'notice' => 'success',
      'alert' => 'warning',
      'error' => 'danger'
    }

    flash.map do |k, title|
      <<-HTML
        <div class="alert alert-#{flash_class[k]}" role="alert">#{title}</div>
      HTML
    end.join('').html_safe
  end

  def icon(name)
    r "<span class=\"button-icon glyphicon glyphicon-#{name}\"></span>"
  end

  def caret
    r "<span class=\"caret\"></span>"
  end

  def group_with_errors(object, name, helper)
    error = object.errors[name]
    error_name = t('attributes.' + name.to_s)
    valid = error.present?
    label_content = helper.label name, class: "col-sm-2 control-label" do
      if valid
        "#{error_name}<div class=\"error-tip\">#{error_name}#{error.join(' ')}</div>"
      else
        "#{error_name}"
      end.html_safe
    end

    s "<div class=\"form-group#{" has-error has-feedback" if valid}\">"
      s "#{label_content}"
      s "<div class=\"col-sm-10\">"
        s "#{yield}"
        s "#{error_block if valid}"
      s "</div>"
    s "</div>"
    nil
  end

  def group_with_property_errors(object, property, helper)
    property_name = "property_#{property.name}"
    error = object.errors[property_name]
    valid = error.present?
    title = object[property_name]
    label_content = helper.label name, class: "col-sm-2 control-label" do
      if valid
        "#{title}<div class=\"error-tip\">#{title}#{error.join(' ')}</div>"
      else
        "#{title}"
      end.html_safe
    end

    s "<div class=\"form-group#{" has-error has-feedback" if valid}\">"
      s "#{label_content}"
      s "<div class=\"col-sm-10\">"
        s "#{yield}"
        s "#{error_block if valid}"
      s "</div>"
    s "</div>"
    nil
  end

  private

  def error_block
    r <<-HTML
      <span class="glyphicon glyphicon-remove form-control-feedback" aria-hidden="true"></span>
      <span class="sr-only">(success)</span>
    HTML
  end


  def r(string)
    raw(string)
  end

  def s(string)
    safe_concat(string)
  end
end
