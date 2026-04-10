class AddFavoritesAndSlugs < ActiveRecord::Migration[8.0]
  def change
    # Favoris
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.timestamps
    end
    add_index :favorites, [:user_id, :listing_id], unique: true

    # Slugs pour SEO
    add_column :listings, :slug, :string
    add_index :listings, :slug, unique: true

    # Views counter pour popularité
    add_column :listings, :views_count, :integer, default: 0, null: false
  end
end
