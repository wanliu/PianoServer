class OneMoney < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include ExpiredEvents

  attribute :name
  attribute :title
  attribute :description

  attribute :start_at, Type::Time
  attribute :end_at, Type::Time

  attribute :cover_url
  attribute :status

  attribute :price, Type::Decimal
  index :name

  expire :start_at, :expired_start_at
  expire :end_at, :expired_end_at

  def to_key
    attributes[:id].nil? ? [] : [id.to_s]
  end

  private

  def expired_start_at
    self.status = 'started'
    save
  end

  def expired_end_at
    self.status = 'end'
    save
  end
end
