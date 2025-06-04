class CreateDisputes < ActiveRecord::Migration[8.0]
  def change
    create_table :disputes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :disputed_item, polymorphic: true, null: false
      t.string :dispute_type, null: false
      t.string :status, null: false, default: 'open'
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :amount, precision: 10, scale: 2
      t.string :priority, default: 'normal'
      t.text :resolution
      t.datetime :resolved_at
      t.bigint :mediator_id
      t.datetime :escalated_at
      t.text :metadata
      t.string :reference_number
      t.boolean :auto_resolved, default: false

      t.timestamps
    end

    add_index :disputes, [:user_id, :status]
    add_index :disputes, [:disputed_item_type, :disputed_item_id]
    add_index :disputes, :dispute_type
    add_index :disputes, :priority
    add_index :disputes, :mediator_id
    add_index :disputes, :reference_number, unique: true
    add_index :disputes, :created_at
    
    add_foreign_key :disputes, :users, column: :mediator_id
  end
end
