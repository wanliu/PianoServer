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
end
