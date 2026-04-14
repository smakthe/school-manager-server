class CreateClassrooms < ActiveRecord::Migration[8.1]
  def change
    create_table :classrooms do |t|
      t.references :school,        null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.integer :grade,            null: false
      t.integer :section,          null: false
      t.bigint  :class_teacher_id, null: false
      t.timestamps
    end

    add_index :classrooms, [ :class_teacher_id, :academic_year_id ],
              unique: true,
              name: "index_classrooms_on_class_teacher_and_year"
    add_index :classrooms, [ :school_id, :academic_year_id, :grade, :section ], unique: true
    add_foreign_key :classrooms, :teachers, column: :class_teacher_id
  end
end
