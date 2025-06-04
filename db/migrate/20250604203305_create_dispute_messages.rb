class CreateDisputeMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :dispute_messages do |t|
      t.references :dispute, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false
      t.string :message_type, default: 'user_message'
      t.string :visibility, default: 'all_parties'
      t.boolean :read_by_user, default: false
      t.boolean :read_by_other_user, default: false
      t.boolean :read_by_mediator, default: false
      t.datetime :edited_at
      t.text :edit_reason

      t.timestamps
    end

    add_index :dispute_messages, [:dispute_id, :created_at]
    add_index :dispute_messages, [:user_id, :dispute_id]
    add_index :dispute_messages, :message_type
    add_index :dispute_messages, :visibility
    add_index :dispute_messages, :created_at
  end
end
