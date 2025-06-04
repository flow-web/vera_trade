class CreateServiceOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :service_offers do |t|
      t.references :service_provider, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :pricing_type
      t.decimal :base_price
      t.string :duration_estimate
      t.integer :status

      t.timestamps
    end
  end
end
