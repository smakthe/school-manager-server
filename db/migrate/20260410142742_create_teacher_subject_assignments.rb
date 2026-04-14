class CreateTeacherSubjectAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :teacher_subject_assignments do |t|
      t.references :teacher,       null: false, foreign_key: true
      t.references :classroom,     null: false, foreign_key: true
      t.references :subject,       null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.timestamps
    end

    add_index :teacher_subject_assignments,
              [ :classroom_id, :subject_id, :academic_year_id ],
              unique: true,
              name: "index_tsa_on_classroom_subject_year"
  end
end
