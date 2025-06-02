class CreateServiceRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :service_requests do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.decimal :budget_min
      t.decimal :budget_max
      t.date :deadline
      t.integer :status
      t.integer :urgency

      t.timestamps
    end
  end
end
