class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.belongs_to :cart
      t.references :cartable, :polymorphic => true
      t.belongs_to :supplier
      t.string :title
      t.string :image
      t.integer :quantity
      t.jsonb :properties
      t.jsonb :condition

      t.timestamps null: false
    end
  end
end
