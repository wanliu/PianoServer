module AdminsHelper

  def admins_object(object)
    [ :admins, *@parents, object ]
  end

  def layout(*args, &block)
    options = args.extract_options!
    default_options = {
      class: [ "row" ] + [ content_for?(:wrapper_layout) ? content_for(:wrapper_layout) : 'normal-layout' ]
    }

    content_tag(:div, options.merge(default_options), &block)
  end
end
