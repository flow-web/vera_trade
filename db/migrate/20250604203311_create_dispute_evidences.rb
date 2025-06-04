class CreateDisputeEvidences < ActiveRecord::Migration[8.0]
  def change
    create_table :dispute_evidences do |t|
      t.references :dispute, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :evidence_type, null: false
      t.string :title, null: false
      t.text :description
      t.string :file_type
      t.bigint :file_size
      t.string :status, default: 'pending_review'
      t.text :review_notes
      t.datetime :reviewed_at
      t.bigint :reviewed_by

      t.timestamps
    end

    add_index :dispute_evidences, [:dispute_id, :evidence_type]
    add_index :dispute_evidences, [:user_id, :dispute_id]
    add_index :dispute_evidences, :evidence_type
    add_index :dispute_evidences, :status
    add_index :dispute_evidences, :created_at
    
    add_foreign_key :dispute_evidences, :users, column: :reviewed_by
  end
end
