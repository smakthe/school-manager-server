class CreateSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :subjects do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name,  null: false
      t.string  :code,  null: false
      t.integer :grade, null: false
      t.timestamps
    end

    add_index :subjects, [ :school_id, :grade, :code ], unique: true
  end
end
