class TemplateBuilder < ActionView::Helpers::FormBuilder

  def dropdown(title, *args, &block)
    @template.dropdown title, *args, &block
  end

  def button_to (title)
    @template.button_new title, @object
  end

  def parents
    @options[:parents]
  end

  def button_new(title, options = {}, &block)
    default_options = {
      method: :get,
      remote: true,
      url: @template.url_for([:new, :admins, *parents, :template ])
    }

    @template.form_for @object.becomes(::Template), options.merge(default_options) do |f|
      f.hidden_field(:name) +
      @template.hidden_field_tag("#{self.class.name.underscore}_id", object_id) +
      f.submit(title, class: %w(btn btn-default))
    end
    # button_to title, new_admins_template, options.merge(default_options), &block
  end
end
