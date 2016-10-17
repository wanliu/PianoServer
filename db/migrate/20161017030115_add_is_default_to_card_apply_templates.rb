class AddIsDefaultToCardApplyTemplates < ActiveRecord::Migration
  def change
    add_column :card_apply_templates, :is_default, :boolean, default: false
    add_index :card_apply_templates, :is_default
  end
end
