class SubjectDrop < Liquid::Rails::Drop
  attributes :id, :name, :title, :description

  def link
    "/subjects/#{@object.id}"
  end

end
