class AddJoinTableSubjectTemplate < ActiveRecord::Migration
  def change
    create_join_table :subjects, :templates do |t|
      # t.index [:subject_id, :template_id]
      # t.index [:template_id, :subject_id]
    end
  end
end
