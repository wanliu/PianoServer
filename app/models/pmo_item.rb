class PmoItem < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include ExpiredEvents

  attribute :title
  attribute :description
  attribute :image_urls, Type::Array
  attribute :cover_urls, Type::Array
  attribute :avatar_urls, Type::Array

  attribute :price, Type::Decimal
  attribute :ori_price, Type::Decimal
  attribute :total_amount, Type::Integer

  attribute :shop_category_name
  attribute :category_name
  attribute :status
  attribute :shop_name
  attribute :shop_avatar_url

  reference :one_money, :OneMoney

  set :participants, :PmoUser
  set :winners, :PmoUser

  counter :completes

  index :title
  # index :id
  def self.from(item)

    new({
      title: item.title,
      description: item.description,
      image_urls: item.images.map(&:url),
      cover_urls: item.images.map {|img| img.url(:cover) },
      avatar_urls:  item.images.map {|img| img.url(:avatar) },
      price: item.price,
      ori_price: item.public_price,
      shop_name: item.shop.title,
      shop_avatar_url: item.shop.avatar_url,
      total_amount: item.current_stock,
      shop_category_name: item.shop_category.try(:title),
      category_name: item.category.try(:title)
    })
  end

  def cover_url
    cover_urls.try :first
  end

  def avatar_url
    avatar_urls.try :first
  end
end
