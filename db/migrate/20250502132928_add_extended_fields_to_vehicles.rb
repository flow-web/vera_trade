class AddExtendedFieldsToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :finition, :string
    add_column :vehicles, :doors, :integer
    add_column :vehicles, :exterior_color, :string
    add_column :vehicles, :interior_material, :string
    add_column :vehicles, :interior_color, :string
    add_column :vehicles, :previous_owners, :integer
    add_column :vehicles, :last_service_date, :date
    add_column :vehicles, :next_ct_date, :date
    add_column :vehicles, :ct_expiry_date, :date
    add_column :vehicles, :has_service_history, :boolean
    add_column :vehicles, :non_smoker, :boolean
    add_column :vehicles, :location, :string
    add_column :vehicles, :safety_features, :text
    add_column :vehicles, :comfort_features, :text
    add_column :vehicles, :multimedia_features, :text
    add_column :vehicles, :exterior_features, :text
    add_column :vehicles, :other_features, :text
    add_column :vehicles, :body_condition, :text
    add_column :vehicles, :interior_condition, :text
    add_column :vehicles, :tire_condition, :text
    add_column :vehicles, :recent_works, :text
    add_column :vehicles, :issues, :text
    add_column :vehicles, :expected_costs, :text
  end
end
