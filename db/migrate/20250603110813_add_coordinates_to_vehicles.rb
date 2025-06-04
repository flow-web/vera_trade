class AddCoordinatesToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :latitude, :decimal, precision: 10, scale: 6
    add_column :vehicles, :longitude, :decimal, precision: 10, scale: 6
    add_column :vehicles, :address, :text
    
    add_index :vehicles, [:latitude, :longitude]
  end
end
