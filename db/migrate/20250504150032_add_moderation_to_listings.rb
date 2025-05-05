class AddModerationToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :moderation_status, :string
    add_column :listings, :moderation_reason, :text
  end
end
