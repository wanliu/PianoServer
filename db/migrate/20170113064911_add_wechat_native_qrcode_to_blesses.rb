class AddWechatNativeQrcodeToBlesses < ActiveRecord::Migration
  def change
    add_column :blesses, :wechat_native_qrcode, :string
  end
end
