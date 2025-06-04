class CreateServiceReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :service_reviews do |t|
      t.references :service_provider, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :service_booking_id, null: true
      t.integer :rating
      t.string :title
      t.text :comment
      t.integer :communication_rating
      t.integer :quality_rating
      t.integer :value_rating

      t.timestamps
    end
  end
end
