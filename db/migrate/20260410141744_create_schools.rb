class CreateSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :schools do |t|
      t.string  :name,      null: false
      t.string  :address
      t.string  :phone
      t.string  :subdomain,  null: false
      t.string  :timezone
      t.integer :board,               null: false
      t.integer :subscription_status, null: false, default: 0
      t.timestamps
    end

    add_index :schools, :subdomain, unique: true
  end
end
