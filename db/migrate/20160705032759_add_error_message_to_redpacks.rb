class AddErrorMessageToRedpacks < ActiveRecord::Migration
  def change
    add_column :redpacks, :error_message, :text
  end
end
