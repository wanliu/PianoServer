class AddExpressTemplateIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :express_template_id, :integer
  end
end
