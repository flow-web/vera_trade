class CreateServiceRequestResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :service_request_responses do |t|
      t.references :service_request, null: false, foreign_key: true
      t.references :service_provider, null: false, foreign_key: true
      t.text :message
      t.decimal :proposed_price
      t.string :estimated_duration

      t.timestamps
    end
  end
end
