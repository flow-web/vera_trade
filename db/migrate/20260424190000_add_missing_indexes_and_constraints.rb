class AddMissingIndexesAndConstraints < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :listings, :status, name: "index_listings_on_status", algorithm: :concurrently

    add_index :messages, :sender_id, name: "index_messages_on_sender_id", algorithm: :concurrently
    add_index :messages, :recipient_id, name: "index_messages_on_recipient_id", algorithm: :concurrently
    add_index :messages, [:recipient_id, :read], name: "index_messages_on_recipient_id_and_read", algorithm: :concurrently

    add_index :users, :kyc_status, name: "index_users_on_kyc_status", algorithm: :concurrently
  end
end
