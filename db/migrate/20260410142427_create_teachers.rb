class CreateTeachers < ActiveRecord::Migration[8.1]
  def change
    create_table :teachers do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name,          null: false
      t.string  :employee_code,  null: false
      t.date    :doj,            null: false
      t.decimal :salary,    precision: 10, scale: 2, null: false
      t.boolean :is_active, null: false, default: true
      t.timestamps
    end

    add_index :teachers, [ :school_id, :employee_code ], unique: true
  end
end
