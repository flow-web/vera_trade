class CreateServiceBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :service_bookings do |t|
      t.references :service_provider, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :service_offer, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.text :description
      t.date :proposed_date
      t.decimal :total_amount
      t.integer :status
      t.integer :payment_status

      t.timestamps
    end
  end
end
