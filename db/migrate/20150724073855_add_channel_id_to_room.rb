class AddChannelIdToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :channel_id, :string
    add_column :rooms, :tokens, :string, array: true
  end
end
