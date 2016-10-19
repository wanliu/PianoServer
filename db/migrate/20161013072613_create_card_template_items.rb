class CreateCardTemplateItems < ActiveRecord::Migration
  def change
    create_table :card_template_items do |t|
      t.references :card_apply_template, index: true
      t.references :item, index: true

      t.timestamps null: false
    end
  end
end
