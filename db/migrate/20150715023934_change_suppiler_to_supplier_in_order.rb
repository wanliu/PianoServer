class ChangeSuppilerToSupplierInOrder < ActiveRecord::Migration
  def change
    rename_column :orders, :suppiler_id, :supplier_id
  end
end
