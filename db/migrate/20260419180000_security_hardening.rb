class SecurityHardening < ActiveRecord::Migration[8.0]
  def change
    remove_column :wallets, :balance_cents, :integer, default: 0, null: false

    add_index :vehicles, :year
    add_index :vehicles, :fuel_type
    add_index :vehicles, :transmission
    add_index :vehicles, :created_at
    add_index :conversations, :updated_at
  end
end
