class CreateCouponTemplateTimes < ActiveRecord::Migration
  def change
    create_table :coupon_template_times do |t|
      t.references :coupon_template, index: true
      t.integer :type
      t.datetime :from
      t.datetime :to
      t.jsonb :expire_duration, default: {}

      t.timestamps null: false
    end
    # add_foreign_key :coupon_template_times, :coupon_templates
  end
end
