class CreateCardApplyTemplates < ActiveRecord::Migration
  def change
    create_table :card_apply_templates do |t|
      t.integer :apply_items, index: true, default: 0

      t.timestamps null: false
    end
  end
end
