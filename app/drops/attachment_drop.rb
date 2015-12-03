class AttachmentDrop < Liquid::Rails::Drop
  attributes :id, :name, :url, :avatar_url, :cover_url
  include ImageUrl

  image_mount :filename

  def url
    object.filename.url
  end

  def to_s
    url
  end

end
