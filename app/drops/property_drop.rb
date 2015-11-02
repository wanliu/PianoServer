class PropertyDrop < Liquid::Rails::Drop
  attributes :id, :name, :summary, :unit_type, :prop_type, :exterior, :created_at, :updated_at


  def exterior_template
    "exterior_#{object.exterior}"
  end
end
