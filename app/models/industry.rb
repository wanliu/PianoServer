class Industry < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  has_many :templates, as: :templable

  class_attribute :default_templates

  enum status: [ :open, :close ]
  mount_uploader :image, ImageUploader

end

Industry.default_templates = [
  PartialTemplate.new(name: 'show', filename: 'views/show.html.liquid', templable: Industry.new)
  # PartialTemplate.new(name: 'edit_options', filename: 'views/_edit_options.html.liquid', templable: Category.new),
  # PageTemplate.new(name: 'item', filename: 'views/_item.html.liquid', templable: Category.new),
  # PageTemplate.new(name: 'items/show', filename: 'views/items/show.html.liquid', templable: Category.new)
]

