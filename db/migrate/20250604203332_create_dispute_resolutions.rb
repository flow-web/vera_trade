class CreateDisputeResolutions < ActiveRecord::Migration[8.0]
  def change
    create_table :dispute_resolutions do |t|
      t.references :dispute, null: false, foreign_key: true
      t.bigint :proposed_by, null: false
      t.string :resolution_type, null: false
      t.text :details, null: false
      t.decimal :amount, precision: 10, scale: 2
      t.string :status, default: 'pending'
      t.text :accepted_by_users
      t.datetime :expires_at
      t.datetime :implemented_at
      t.text :implementation_notes
      t.text :rejection_reason

      t.timestamps
    end

    add_index :dispute_resolutions, [:dispute_id, :status]
    add_index :dispute_resolutions, :proposed_by
    add_index :dispute_resolutions, :resolution_type
    add_index :dispute_resolutions, :status
    add_index :dispute_resolutions, :expires_at
    add_index :dispute_resolutions, :created_at
    
    add_foreign_key :dispute_resolutions, :users, column: :proposed_by
  end
end
