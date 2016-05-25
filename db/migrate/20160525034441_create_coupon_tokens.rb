class CreateCouponTokens < ActiveRecord::Migration
  def change
    create_table :coupon_tokens do |t|
      t.references :coupon_template, index: true
      t.references :customer, index: true
      t.string :token, index: true
      t.integer :lock_version, default: 0

      t.timestamps null: false
    end
    # add_foreign_key :coupon_tokens, :coupon_templates
    # add_foreign_key :coupon_tokens, :customers
  end
end
