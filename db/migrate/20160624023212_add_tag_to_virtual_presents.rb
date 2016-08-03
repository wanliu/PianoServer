class AddTagToVirtualPresents < ActiveRecord::Migration
  def change
    add_column :virtual_presents, :title, :string

    VirtualPresent.find_each do |present|
      present.update_attribute('title', present.name)
    end
  end
end
