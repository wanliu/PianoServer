class CreateSalesMen < ActiveRecord::Migration
  def change
    create_table :sales_men do |t|
      t.references :user, index: true
      t.references :shop, index: true

      t.timestamps null: false
    end
  end
end
