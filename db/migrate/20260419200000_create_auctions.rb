class CreateAuctions < ActiveRecord::Migration[8.0]
  def change
    create_table :auctions do |t|
      t.references :listing, null: false, foreign_key: true, index: { unique: true }
      t.decimal :starting_price, precision: 10, scale: 2, null: false
      t.decimal :reserve_price, precision: 10, scale: 2
      t.decimal :current_price, precision: 10, scale: 2
      t.string :status, default: "scheduled", null: false
      t.integer :duration_days, default: 7, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :bids_count, default: 0, null: false
      t.integer :watchers_count, default: 0, null: false
      t.decimal :seller_fee_pct, precision: 4, scale: 2, default: 5.0, null: false
      t.decimal :buyer_fee_pct, precision: 4, scale: 2, default: 4.5, null: false
      t.timestamps
    end

    add_index :auctions, :status
    add_index :auctions, :ends_at

    create_table :bids do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :bidder, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.boolean :proxy, default: false, null: false
      t.decimal :max_proxy_amount, precision: 10, scale: 2
      t.timestamps
    end

    add_index :bids, [:auction_id, :created_at]

    create_table :auction_watchers do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :auction_watchers, [:auction_id, :user_id], unique: true
  end
end
