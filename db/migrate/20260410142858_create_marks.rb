class CreateMarks < ActiveRecord::Migration[8.1]
  def change
    create_table :marks do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :subject,    null: false, foreign_key: true
      t.integer :term,      null: false
      t.decimal :score,     precision: 5, scale: 2, null: false
      t.decimal :max_score, precision: 5, scale: 2, null: false
      t.timestamps
    end

    add_index :marks, [ :enrollment_id, :subject_id, :term ],
              unique: true,
              name: "index_marks_on_enrollment_subject_term"
  end
end
