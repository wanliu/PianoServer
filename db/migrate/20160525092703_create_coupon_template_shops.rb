class CreateCouponTemplateShops < ActiveRecord::Migration
  def change
    create_table :coupon_template_shops do |t|
      t.references :coupon_template, index: true
      t.references :shop, index: true
      t.integer :type, index: true

      t.timestamps null: false
    end
  end
end
