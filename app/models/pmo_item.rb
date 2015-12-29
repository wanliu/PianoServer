class OneMoney < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include ExpiredEvents


  attribute :title, Type::String
  attribute :image_urls, Type::Array
