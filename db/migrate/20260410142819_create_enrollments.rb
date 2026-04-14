class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :student,       null: false, foreign_key: true
      t.references :classroom,     null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :enrollments, [ :student_id, :academic_year_id ], unique: true
  end
end
