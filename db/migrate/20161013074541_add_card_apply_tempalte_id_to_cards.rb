class AddCardApplyTempalteIdToCards < ActiveRecord::Migration
  def change
    add_reference :cards, :card_apply_template, index: true
    add_column :card_apply_templates, :title, :string
    add_index :card_apply_templates, :title
  end
end
