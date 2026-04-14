class CreateAdmins < ActiveRecord::Migration[8.1]
  def change
    create_table :admins do |t|
      t.timestamps
    end
  end
end
