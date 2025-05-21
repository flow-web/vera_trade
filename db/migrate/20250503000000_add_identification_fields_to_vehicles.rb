class AddIdentificationFieldsToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :license_plate, :string
    add_column :vehicles, :fiscal_power, :integer
    add_column :vehicles, :average_consumption, :decimal, precision: 5, scale: 2
    add_column :vehicles, :co2_emissions, :integer
    add_column :vehicles, :is_draft, :boolean, default: false
    
    add_index :vehicles, :license_plate, unique: true
    add_index :vehicles, :vin, unique: true
  end
end 