class ChangeWxPrepareIdToWxPrepayId < ActiveRecord::Migration
  def change
    rename_column :orders, :wx_prepare_id, :wx_prepay_id
  end
end
