class AddWxCardInfoToCard < ActiveRecord::Migration
  def change
    add_column :cards, :kind, :integer
    add_column :cards, :base_info, :jsonb
    add_column :cards, :deal_detail, :jsonb
    add_column :cards, :gift, :string
    add_column :cards, :least_cost, :integer
    add_column :cards, :reduce_cost, :integer
    add_column :cards, :discount, :integer
  end
end
