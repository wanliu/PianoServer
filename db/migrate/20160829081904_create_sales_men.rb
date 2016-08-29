class CreateSalesMen < ActiveRecord::Migration
  def change
    create_table :sales_men do |t|
      t.references :user, index: true, foreign_key: true
      t.references :shop, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
