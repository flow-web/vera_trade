class CreateServiceProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :service_providers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.text :description
      t.string :phone
      t.text :address
      t.string :city
      t.string :postal_code
      t.decimal :latitude
      t.decimal :longitude
      t.text :specialties
      t.string :website
      t.integer :status
      t.integer :verification_status
      t.decimal :average_rating
      t.integer :total_reviews
      t.datetime :suspended_until

      t.timestamps
    end
  end
end
