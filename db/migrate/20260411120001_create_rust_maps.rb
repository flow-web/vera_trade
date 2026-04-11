class CreateRustMaps < ActiveRecord::Migration[8.0]
  def change
    create_table :rust_maps do |t|
      t.references :listing, null: false, foreign_key: true, index: { unique: true }
      t.string :silhouette_variant, null: false, default: "sedan"
      t.integer :transparency_score, default: 100
      t.text :notes
      t.timestamps
    end
  end
end
