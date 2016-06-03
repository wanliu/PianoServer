class AddPropertiesToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :properties, :jsonb, default: {}
  end
end
