class AddEnhancedFieldsToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :status, :string
    add_column :messages, :message_type, :string
    add_column :messages, :read_at, :datetime
    add_column :messages, :attachment_data, :text
    add_column :messages, :reactions, :text
  end
end
