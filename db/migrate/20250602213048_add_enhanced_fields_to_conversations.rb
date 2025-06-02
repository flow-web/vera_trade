class AddEnhancedFieldsToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :archived_by_user, :boolean
    add_column :conversations, :archived_by_other_user, :boolean
    add_reference :conversations, :listing, null: false, foreign_key: true
    add_column :conversations, :status, :string
    add_column :conversations, :last_activity_at, :datetime
  end
end
