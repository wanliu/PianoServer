class AddAvatarMediaIdToBirthdayParties < ActiveRecord::Migration
  def change
    add_column :birthday_parties, :avatar_media_id, :string
  end
end
