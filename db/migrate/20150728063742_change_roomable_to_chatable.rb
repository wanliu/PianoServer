class ChangeRoomableToChatable < ActiveRecord::Migration
  def change
    rename_column :chats, :roomable_type, :chatable_type
    rename_column :chats, :roomable_id, :chatable_id
  end
end
