class AddTypeToTeachers < ActiveRecord::Migration[8.1]
  def change
    add_column :teachers, :type, :string, default: 'Teacher', null: false
    add_index :teachers, :type
  end
end
