class CreateTicketMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_messages do |t|
      t.references :support_ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false
      t.string :message_type, default: 'user_message'
      t.boolean :internal, default: false
      t.boolean :read_by_user, default: false
      t.boolean :read_by_admin, default: false
      t.datetime :edited_at
      t.text :edit_reason

      t.timestamps
    end

    add_index :ticket_messages, [:support_ticket_id, :created_at]
    add_index :ticket_messages, [:user_id, :support_ticket_id]
    add_index :ticket_messages, :message_type
    add_index :ticket_messages, :internal
    add_index :ticket_messages, :created_at
  end
end
