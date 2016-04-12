class PmoSeed < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :seed_id, String
  reference :one_money, :OneMoney
  reference :pmo_item, :PmoItem

  reference :given, :PmoUser
  reference :owner, :PmoUser

end
