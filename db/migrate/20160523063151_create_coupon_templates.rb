class CreateCouponTemplates < ActiveRecord::Migration
  def change
    create_table :coupon_templates do |t|
      t.references :issuer, polymorphic: true, index: true
      t.string :name
      t.decimal :par, precision: 10, scale: 2
      t.integer :apply_items
      t.decimal :apply_minimal_total, precision: 10, scale: 2
      t.integer :apply_shops
      t.integer :apply_time
      t.boolean :overlap

      t.timestamps null: false
    end
  end
end
