class AddPropertiesToItem < ActiveRecord::Migration
  def change
    add_column :items, :properties, :jsonb, default: {}
  end
end
