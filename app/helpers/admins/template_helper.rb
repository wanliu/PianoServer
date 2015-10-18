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

  def form_for(*args, &block)
    pp self.class.ancestors
    super *args, &block
  end

  def ace_editor(*args, &block)
    super *args, &block
  end

  def new_admins_template
    [:new, :admins, *@parents, :template ]
  end

  def button_new(title, template, options = {}, &block)
    default_options = {
      method: :get,
      url: url_for(new_admins_template)
    }

    form_for template.becomes(::Template), options.merge(default_options) do |f|
      f.hidden_field(:name) +
      f.submit(title, class: %w(btn btn-default))
    end
    # button_to title, new_admins_template, options.merge(default_options), &block
  end

  # def url_for_template(template)
  #   urls = [:admins, *@parents, template.becomes(::Template)]
  #   urls.unshift(:new) if @edit_mode
  #   urls
  # end

  default_options :template_panel, class: "tab-pane fade panel panel-default"
  default_options :button_new, class: 'btn btn-default button_new', remote: true
  default_options :ace_editor, class: 'source-editor'
  default_options :form_for, build: ::TemplateBuilder
end
