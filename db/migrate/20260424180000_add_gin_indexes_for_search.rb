class AddGinIndexesForSearch < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    enable_extension "pg_trgm"

    add_index :listings, :title, using: :gin, opclass: :gin_trgm_ops,
              name: "index_listings_on_title_gin", algorithm: :concurrently
    add_index :listings, :description, using: :gin, opclass: :gin_trgm_ops,
              name: "index_listings_on_description_gin", algorithm: :concurrently
    add_index :vehicles, :make, using: :gin, opclass: :gin_trgm_ops,
              name: "index_vehicles_on_make_gin", algorithm: :concurrently
    add_index :vehicles, :model, using: :gin, opclass: :gin_trgm_ops,
              name: "index_vehicles_on_model_gin", algorithm: :concurrently
  end
end
