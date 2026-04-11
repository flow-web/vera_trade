class CreateProvenanceEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :provenance_events do |t|
      t.references :listing, null: false, foreign_key: true
      t.integer :event_year, null: false
      t.string :event_type, null: false, default: "service"
      t.string :label, null: false
      t.text :description
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :provenance_events, [ :listing_id, :position ]
    add_index :provenance_events, :event_year
  end
end
