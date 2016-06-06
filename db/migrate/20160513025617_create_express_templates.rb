class CreateExpressTemplates < ActiveRecord::Migration
  def change
    create_table :express_templates do |t|
      t.references :shop, index: true
      t.string :name
      t.boolean :free_shipping, default: false
      t.jsonb :template, default: {}

      t.timestamps null: false
    end
    # add_foreign_key :express_templates, :shops
  end
end
