class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.references :coupon_template, index: true
      t.references :receiver_shop, index: true
      t.datetime :receiv_time
      t.references :receive_taget, polymorphic: true, index: true
      t.references :customer, index: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status, default: 0

      t.timestamps null: false
    end
    # add_foreign_key :coupons, :coupon_templates
    # add_foreign_key :coupons, :receiver_shops
    # add_foreign_key :coupons, :customers
  end
end
