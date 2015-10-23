class ChangeTemplatesToPolymorphic < ActiveRecord::Migration
  def up
    change_table :templates do |t|
      t.references :templable, :polymorphic => true
    end

    remove_column :templates, :subject_id
  end

  def down
    change_table :templates do |t|
      t.remove_references :templable, :polymorphic => true
    end

    add_column :templates, :subject_id, :integer
  end
end
