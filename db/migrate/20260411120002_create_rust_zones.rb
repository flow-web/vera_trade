class CreateRustZones < ActiveRecord::Migration[8.0]
  def change
    create_table :rust_zones do |t|
      t.references :rust_map, null: false, foreign_key: true
      t.decimal :x_pct, precision: 5, scale: 2, null: false
      t.decimal :y_pct, precision: 5, scale: 2, null: false
      t.string :status, null: false, default: "ok"
      t.string :label
      t.text :note
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :rust_zones, [ :rust_map_id, :position ]
  end
end
