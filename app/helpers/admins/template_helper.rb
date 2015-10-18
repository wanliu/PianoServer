module Admins::TemplateHelper
  include DefaultOptionsHelper

  def template_panel(template, *args, &block)
    options = args.extract_options!

    builder = TemplateBuilder.new 'template', template, self, {parents: @parents}

    default_options = {
      id: template.name,
      "template-panel-id": builder.object_id
    }

    default_options[:class] = options[:class] + " active in" if @edit_mode

    content_tag :div, options.merge(default_options) do
      block.call(builder) if block
    end
  end

  def new_admins_template
    [:new, :admins, *@parents, :template ]
  end

  def ace_editor(template, *args, &block)
    options = args.extract_options!
    options[:url] = template.persisted?  ? [:admins, *@parents, template.becomes(::Template)] : [:admins, *@parents, :templates]
    options[:url] = url_for(options[:url])
    args.push options
    super template, *args, &block
  end

  def button_new(title, template, options = {}, &block)
    default_options = {
      method: :get,
      url: url_for(new_admins_template)
    }

    form_for template.becomes(::Template), options.merge(default_options) do |f|
      f.hidden_field(:name) +
      f.hidden_field(:filename) +
      f.submit(title, class: %w(btn btn-default))
    end
    # button_to title, new_admins_template, options.merge(default_options), &block
  end

  def button(*args, &block)
    options = args.extract_options!

    bind = options.delete(:bind) || BindHelper::BindOptions.new(nil)
    bind_options = bind && bind.to_options
    args.push options.merge(bind_options)
    super *args, &block
  end

  default_options :template_panel, class: "tab-pane fade panel panel-default"
  default_options :button_new, class: 'btn btn-default button_new', remote: true
  default_options :ace_editor, class: 'source-editor', theme: 'solarized_dark'
  default_options :form_for, build: ::TemplateBuilder
end
