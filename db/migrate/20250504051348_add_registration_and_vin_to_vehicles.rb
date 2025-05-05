class AddRegistrationAndVinToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :registration, :string
    add_column :vehicles, :vin, :string
  end
end
