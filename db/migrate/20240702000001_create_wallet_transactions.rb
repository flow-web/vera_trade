class CreateWalletTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :wallet_transactions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :currency, default: "EUR", null: false
      t.integer :transaction_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.string :reference
      t.text :notes

      t.timestamps
    end
    
    add_index :wallet_transactions, :transaction_type
    add_index :wallet_transactions, :status
    add_index :wallet_transactions, :reference
  end
end 