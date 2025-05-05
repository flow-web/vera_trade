class AddBuyerIdToListings < ActiveRecord::Migration[8.0]
  def change
    add_reference :listings, :buyer, foreign_key: { to_table: :users }, null: true
  end
end 