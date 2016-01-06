module BootstrapHelper

  def bootstrap_flash
    flash_class = {
      'notice' => 'success',
      'alert' => 'warning',
      'error' => 'danger'
    }

    flash.map do |k, title|
      if title.is_a? Hash
        @title = title["msg"]
        @url = title["url"]
        @prompt = title["prompt"]
      else
        @title = title
      end
      <<-HTML
        <div class="alert alert-#{flash_class[k]} alert-dismissible" role="alert">
          <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <strong>#{t(k, scope: 'flash.titles')}!</strong>&nbsp;#{@title} #{link_to @prompt, @url if @url}</div>
      HTML
    end.join('').html_safe
  end

  # def icon(name)
  #   r "<span class=\"button-icon glyphicon glyphicon-#{name}\"></span>"
  # end

  def close
    html = <<-HTML
      <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    HTML
    html.html_safe
  end

  def close_to(url, options = {}, html_options = {})
    default_html_options = {
      class: "close",
      "aria-label" => "Close"
    }

    button_to url, options, html_options.merge(default_html_options) do
      "<span aria-hidden=\"true\">&times;</span>".html_safe
    end
  end

  def caret
    r "<span class=\"caret\"></span>"
  end

  def badge(value)
    r "<span class=\"badge\">#{value}</span>"
  end

  def group_with_errors(object, name, helper, options = {}, &block)
    layout = options.delete(:layout) || 'horizontal'
    if layout == 'horizontal'
      group_by_horizontal(object, name, helper, options, &block)
    else
      group_by_normal(object, name, helper, options, &block)
    end
  end

  def group_by_horizontal(object, name, helper, options = {}, &block)
    # error = object.errors[name]
    # error_name = t('attributes.' + name.to_s)
    # valid = error.present?
    valid = has_errors(object, name)
    error = error_message(object, name)
    error_name = t('attributes.' + name.to_s)
    title = options[:title] || t(name, scope: "attributes")

    if true == options[:required]
      title << "<span class='required'>*</span>".html_safe
    end

    label_content = helper.label name, title, class: "col-sm-2 control-label" do
      if valid
        "#{error_name}<div class=\"error-tip\">#{error_name}#{error.join(' ')}</div>"
      elsif true == options[:required]
        "#{error_name}<span class='required'>*</span>".html_safe
      else
        "#{error_name}"
      end.html_safe
    end

    s "<div class=\"form-group#{" has-error has-feedback" if valid} #{options[:group_class]} \">"
      s "#{label_content}"
      s "<div class=\"col-sm-10\">"
        s "#{yield}"
        s "#{error_block if valid}"
      s "</div>"
    s "</div>"
    nil
  end

  def group_by_normal(object, name, helper, options = {}, &block)
    # error = object.errors[name]
    # error_name = t('attributes.' + name.to_s)
    # valid = error.present?
    valid = has_errors(object, name)
    error = error_message(object, name)
    error_name = t('attributes.' + name.to_s)
    title = options[:title] || t(name, scope: "attributes")


    label_content = helper.label name, class: "control-label" do
      if true == options[:required]
        "#{title}<span class='required'>*</span>".html_safe
      else
        "#{title}"
      end
    end

    error_label = "<span class=\"help-block text-left\">#{error_name}#{error.join(' ')}</span>".html_safe

    s "<div class=\"form-group#{" has-error has-feedback" if valid} #{options[:group_class]} \">"
      s "#{label_content}"
      group_with_input_group options do
        s "#{yield}"
      end
      s "#{error_label if valid}"
    s "</div>"
    nil
  end

  def group_with_input_group(options = {}, &block)
    if options[:input_group]
      s  "<div class=\"input-group\">"
        yield
      s  "</div>"
    else
      yield
    end
  end

  def group_with_property_errors(object, property, helper, options = {})
    property_name = "property_#{property.name}"

    error = object.errors[property_name]
    valid = error.present?
    title = "#{property.title}".html_safe
    label_content = helper.label property_name, class: "col-sm-2 control-label", title: property.name do
      if valid
        "#{title}<div class=\"error-tip\">#{title}#{error.join(' ')}</div>"
      else
        "#{title}"
      end.html_safe
    end

    s "<div class=\"form-group#{" has-error has-feedback" if valid} #{options[:group_class]}\">"
      s "#{label_content}"
      s "<div class=\"col-sm-10\">"
        s "#{yield}"
        s "#{error_block if valid}"
      s "</div>"
    s "</div>"
    nil
  end

  def has_errors(object, name)
    errors = error_message(object, name)
    errors.length > 0
  end

  def error_message(object, name)
    name = name.to_s
    keys = object.errors.keys.select {|msg| msg = msg.to_s; msg == name or msg.start_with? "#{name}." }

    keys.map do |key|
      if key.to_s.split('.').length > 1
        object.errors.full_messages_for key
      else
        object.errors[key]
      end
    end
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
