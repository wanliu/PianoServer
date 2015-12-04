class AddTimestampsToOrder < ActiveRecord::Migration
  def change
    add_timestamps :orders

    now = Time.now
    Order.find_each do |order|
      order.update(created_at: now, updated_at: now) if order.created_at.blank?
    end

    change_column_null :orders, :created_at, false
    change_column_null :orders, :updated_at, false
  end
end
