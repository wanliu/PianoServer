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
    valid = object.errors[name].present?

    s "<div class=\"form-group#{" has-error has-feedback" if valid}\">"
      s "#{helper.label name, class: "col-sm-2 control-label"}"
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
