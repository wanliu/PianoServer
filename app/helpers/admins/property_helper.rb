module Admins::PropertyHelper


  def container_class
    container? ? ".@container" : ""
  end

  def container?
    params[:container].presence
  end

  def property_class(property)
    classes = [ ".property-#{property.id}" ]
    classes.unshift container_class if container?
    classes.join(' ')
  end

  def property_item(property, options = {}, &block)
    options_class = options[:class] && options[:class].is_a?(Array) ? options[:class] : [ options[:class] ]
    default_class = [
      "list-group-item",
      "property-#{property.id}",
      property.upperd? ? "property-inherits" : "",
      property.inhibit? ? "disabled" : "",
    ]

    default_options = {
      class: default_class + options_class,
      data: {
        id: property.id
      }
    }

    content_tag :li, options.merge(default_options) , &block
  end
end
