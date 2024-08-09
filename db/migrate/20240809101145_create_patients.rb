class CreatePatients < ActiveRecord::Migration[7.1]
  def change
    create_table :patients do |t|
      t.string :first_name
      t.string :last_name
      t.string :birth_date
      t.string :phone
      t.string :address

      t.timestamps
    end
  end
end
