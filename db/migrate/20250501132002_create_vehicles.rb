class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.string :make
      t.string :model
      t.integer :year
      t.text :description
      t.decimal :price
      t.integer :kilometers
      t.string :fuel_type
      t.string :transmission

      t.timestamps
    end
  end
end
