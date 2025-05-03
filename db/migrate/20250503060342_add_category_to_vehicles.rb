class AddCategoryToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_reference :vehicles, :category, foreign_key: true
    add_column :vehicles, :subcategory, :string
    add_column :vehicles, :custom_type, :string
    
    # Champs spécifiques pour les différents types de véhicules
    add_column :vehicles, :cylinder_capacity, :integer
    add_column :vehicles, :engine_type, :string
    add_column :vehicles, :cooling_type, :string
    add_column :vehicles, :starter_type, :string
    add_column :vehicles, :license_type, :string
    add_column :vehicles, :length, :decimal, precision: 10, scale: 2
    add_column :vehicles, :width, :decimal, precision: 10, scale: 2
    add_column :vehicles, :draft, :decimal, precision: 10, scale: 2
    add_column :vehicles, :hull_material, :string
    add_column :vehicles, :number_of_cabins, :integer
    add_column :vehicles, :number_of_berths, :integer
    add_column :vehicles, :engine_hours, :integer
    add_column :vehicles, :drive_type, :string
    add_column :vehicles, :transmission_type, :string
    add_column :vehicles, :number_of_seats, :integer
    add_column :vehicles, :flight_hours, :integer
    add_column :vehicles, :number_of_engines, :integer
    add_column :vehicles, :ceiling, :integer
    add_column :vehicles, :range, :integer
    add_column :vehicles, :operating_hours, :integer
    add_column :vehicles, :lifting_capacity, :decimal, precision: 10, scale: 2
    add_column :vehicles, :maximum_reach, :decimal, precision: 10, scale: 2
    add_column :vehicles, :additional_equipment, :text
    add_column :vehicles, :bucket_capacity, :decimal, precision: 10, scale: 2
    add_column :vehicles, :loading_capacity, :decimal, precision: 10, scale: 2
    add_column :vehicles, :towing_capacity, :decimal, precision: 10, scale: 2
    add_column :vehicles, :axles, :integer
    add_column :vehicles, :sleeping_cab, :boolean
    add_column :vehicles, :emission_standard, :string
  end
end 