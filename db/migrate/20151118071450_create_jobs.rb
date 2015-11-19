class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :status
      t.references :jobable, polymorphic: true
      t.string :job_type
      t.jsonb :input, default: {}
      t.jsonb :output, default: {}
      t.datetime :end_at
      t.datetime :start_at

      t.timestamps null: false
    end
  end
end
