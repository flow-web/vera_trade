class AddIsCertifiedToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :is_certified, :boolean, default: false
  end
end 