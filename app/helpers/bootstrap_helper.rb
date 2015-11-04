module BootstrapHelper

  def bootstrap_flash
    flash_class = {
      'notice' => 'success',
      'alert' => 'warning',
      'error' => 'danger'
    }

    flash.map do |k, title|
      <<-HTML
        <div class="alert alert-#{flash_class[k]} alert-dismissible" role="alert">
          <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <strong>#{t(k, scope: 'flash.titles')}!</strong>&nbsp;#{title}</div>
      HTML
    end.join('').html_safe
  end

  # def icon(name)
  #   r "<span class=\"button-icon glyphicon glyphicon-#{name}\"></span>"
  # end

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
    title = "#{property.title}&nbsp;<small>#{property.name}</small>".html_safe
    label_content = helper.label property_name, class: "col-sm-2 control-label" do
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

  # def page_heading(title = nil, &block)
  #   r <<-HTML
  #     <div class="panel-heading">
  #       <h3 class="panel-title">
  #         #{title}#{yield if block_given?}
  #       </h3>
  #     </div>
  #   HTML
  # end

  def sm(sub_title = nil, &block)
    content_tag :small, sub_title
  end

  def link_to_modal(modal, *args, &block)
    options = args.extract_options!
    default_options = { data: { toggle: :modal, target: modal } }
    link_to *args, options.deep_merge(default_options), &block
  end

  def link_to_void(*args, &block)
    void = 'javascript:void(0)'

    if block_given?
      args.unshift void
    else
      title = args.shift
      args.unshift void
      args.unshift title
    end

    link_to *args, &block
  end

  def row(*args, &block)
    options = args.extract_options!
    default_options = {
      class: 'row'
    }

    content_tag(:div, options.merge(default_options), &block)
  end

  def col(col_options, options = {}, &block)
    default_type = "md"
    col_classes =
      case col_options
      when Fixnum
        [["col", default_type, col_options].join('-')]
      when Hash
        col_options.slice(:xs, :sm, :md, :lg).map {|k,v| ["col", k, v].join('-') }
      when String
        [ col_options ]
      end

    options[:class] =
      case options[:class]
      when Array
        options[:class].dup + col_classes
      when String
        col_classes.push(options[:class])
      else
        col_classes
      end

    content_tag(:div, options, &block)
  end

  def input_group(*args, &block)
    options = args.extract_options!

    default_options = {
      class: ["input-group", options[:class] ].join(' ')
    }

    content_tag(:div, options.merge(default_options), &block)
  end

  def addon(*args, &block)
    options = args.extract_options!

    default_options = {
      class: "input-group-addon"
    }

    content_tag(:span, *args, options.merge(default_options), &block)
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
