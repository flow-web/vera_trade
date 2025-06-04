class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.string :favoritable_type
      t.integer :favoritable_id
      t.string :name
      t.text :notes

      t.timestamps
    end
  end
end
