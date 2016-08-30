class AddSupplierToCakes < ActiveRecord::Migration
  def change
    add_column :cakes, :supplier, :string
    add_index :cakes, :supplier

    Cake.all.each do |cake|
      cake.update_column("supplier", "亿金蛋糕")
    end
  end
end
