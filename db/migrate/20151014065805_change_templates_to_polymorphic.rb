class ChangeTemplatesToPolymorphic < ActiveRecord::Migration
  def up
    change_table :templates do |t|
      t.references :templable, :polymorphic => true
      t.remove_column :subject_id
    end
  end

  def down
    change_table :templates do |t|
      t.remove_references :templable, :polymorphic => true
      t.add_column :subject_id, :integer
    end
  end
end
end
