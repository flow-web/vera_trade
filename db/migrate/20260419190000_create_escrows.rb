class CreateEscrows < ActiveRecord::Migration[8.0]
  def change
    create_table :escrows do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: "EUR", null: false
      t.string :status, default: "pending", null: false
      t.string :stripe_payment_intent_id
      t.string :stripe_transfer_id
      t.text :notes
      t.datetime :paid_at
      t.datetime :released_at
      t.datetime :disputed_at
      t.datetime :refunded_at
      t.timestamps
    end

    add_index :escrows, :status
    add_index :escrows, :stripe_payment_intent_id, unique: true, where: "stripe_payment_intent_id IS NOT NULL"
  end
end
