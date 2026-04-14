class CreateAcademicYears < ActiveRecord::Migration[8.1]
  def change
    create_table :academic_years do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name,       null: false
      t.date    :start_date,  null: false
      t.date    :end_date,    null: false
      t.boolean :is_current, null: false, default: false
      t.timestamps
    end

    add_index :academic_years, [ :school_id, :is_current ]
    add_index :academic_years, [ :school_id, :name ], unique: true
  end
end
