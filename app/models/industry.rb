class Industry < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  has_many :templates, as: :templable
  belongs_to :category

  class_attribute :default_templates

  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  enum status: [ :open, :close ]
  mount_uploader :image, ItemImageUploader

end

Industry.default_templates = [
  PartialTemplate.new(name: 'show', filename: 'views/show.html.liquid', templable: Industry.new)
  # PartialTemplate.new(name: 'edit_options', filename: 'views/_edit_options.html.liquid', templable: Category.new),
  # PageTemplate.new(name: 'item', filename: 'views/_item.html.liquid', templable: Category.new),
  # PageTemplate.new(name: 'items/show', filename: 'views/items/show.html.liquid', templable: Category.new)
]

