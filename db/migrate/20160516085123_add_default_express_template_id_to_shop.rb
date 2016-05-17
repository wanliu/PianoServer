class AddDefaultExpressTemplateIdToShop < ActiveRecord::Migration
  def change
    add_column :shops, :default_express_template_id, :integer
  end
end
