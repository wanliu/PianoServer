class AddWechatNativeQrcodeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :wechat_native_qrcode, :string
  end
end
