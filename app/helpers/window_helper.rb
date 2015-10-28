module WindowHelper

  def window(title, options = {}, &block)
    default_options = {
      class: ['window', options[:class]]
    }

    inner_options = options[:inner] || { class: 'window-content' }

    render partial: "shards/window", locals: {
      title: title,
      inline_block: block,
      options: options.merge(default_options),
      inner_options: inner_options
    }
  end
end
