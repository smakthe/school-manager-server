class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name,             null: false
      t.date    :dob,              null: false
      t.integer :gender,           null: false
      t.string  :admission_number, null: false
      t.timestamps
    end

    add_index :students, [ :school_id, :admission_number ], unique: true
  end
end
