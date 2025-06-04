class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.string :priority, default: 'normal'
      t.string :status, null: false, default: 'open'
      t.string :category, null: false
      t.bigint :assigned_to
      t.string :ticket_number
      t.text :tags
      t.datetime :resolved_at
      t.text :resolution_notes
      t.decimal :satisfaction_rating, precision: 3, scale: 2
      t.text :satisfaction_feedback

      t.timestamps
    end

    add_index :support_tickets, [:user_id, :status]
    add_index :support_tickets, :priority
    add_index :support_tickets, :category
    add_index :support_tickets, :assigned_to
    add_index :support_tickets, :ticket_number, unique: true
    add_index :support_tickets, :created_at
    
    add_foreign_key :support_tickets, :users, column: :assigned_to
  end
end
