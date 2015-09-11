class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end

class ImagesDrop < Liquid::Drop

  def initialize(images)
    @images = images
  end

  def before_method(id_or_name)
    if id_or_name.is_a?(String)
      if id_or_name.is_i?
        find_by_id(id_or_name.to_i)
      else
        find_by_name(id_or_name)
      end
    elsif id_or_name.is_a?(Fixnum)
      find_by_id(id_or_name)
    else
      nil
    end
  end

  private

  def find_by_id(id)
    @images.find {|img| img.id == id }
  end

  def find_by_name(name)
    @images.find { |img| img.name == name }
  end
end
