class CreateKycDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :kyc_documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :document_type, null: false
      t.string :status, default: "pending", null: false
      t.text :rejection_reason
      t.datetime :reviewed_at
      t.bigint :reviewed_by_id
      t.timestamps
    end

    add_index :kyc_documents, [:user_id, :document_type]
    add_index :kyc_documents, :status
    add_foreign_key :kyc_documents, :users, column: :reviewed_by_id
  end
end
