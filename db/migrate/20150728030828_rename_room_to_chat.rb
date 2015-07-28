class RenameRoomToChat < ActiveRecord::Migration
  def change
    rename_table :rooms, :chats
  end
end
