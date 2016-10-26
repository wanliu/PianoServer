class AddWxExpiredAtToRedpack < ActiveRecord::Migration
  def change
    add_column :redpacks, :wx_expired_at, :date
  end
end
