class AttachmentDrop < Liquid::Rails::Drop
  attributes :id, :name, :url, :avatar_url, :cover_url

  def url
    object.filename.url
  end

  def avatar_url
    object.filename.url(:avatar)
  end

  def cover_url
    object.filename.url(:cover)
  end

  def to_s
    url
  end

end
