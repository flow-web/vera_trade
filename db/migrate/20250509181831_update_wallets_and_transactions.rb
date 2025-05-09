class UpdateWalletsAndTransactions < ActiveRecord::Migration[7.1]
  def up
    # Vérifier si la table wallets existe déjà
    unless table_exists?(:wallets)
      create_table :wallets do |t|
        t.references :user, null: false, foreign_key: true
        t.decimal :balance, precision: 10, scale: 2, default: 0, null: false
        t.timestamps
      end
    end

    # Vérifier si la table wallet_transactions existe déjà
    unless table_exists?(:wallet_transactions)
      create_table :wallet_transactions do |t|
        t.references :wallet, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.decimal :amount, precision: 10, scale: 2, null: false
        t.string :transaction_type, null: false
        t.string :description
        t.jsonb :metadata, default: {}
        t.timestamps
      end

      add_index :wallet_transactions, :transaction_type
    end
  end

  def down
    drop_table :wallet_transactions if table_exists?(:wallet_transactions)
    drop_table :wallets if table_exists?(:wallets)
  end
end
