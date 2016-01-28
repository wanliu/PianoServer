class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.references :evaluationable, polymorphic: true, index: true
      t.references :user, index: true
      t.references :order, index: true
      t.boolean :hidden, default: false
      t.string :desc
      t.jsonb :items, default: {}

      t.timestamps null: false
    end
  end
end
