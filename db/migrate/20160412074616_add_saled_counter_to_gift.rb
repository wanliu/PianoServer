class AddSaledCounterToGift < ActiveRecord::Migration
  def change
    add_column :gifts, :saled_counter, :integer, default: 0
  end
end
