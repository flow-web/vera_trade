class AddWizardFieldsToListings < ActiveRecord::Migration[8.0]
  def change
    change_table :listings do |t|
      t.jsonb :draft_data, default: {}, null: false
      t.integer :wizard_step, default: 0, null: false
      t.datetime :published_at
    end

    add_index :listings, :published_at
    add_index :listings, :wizard_step
  end
end
