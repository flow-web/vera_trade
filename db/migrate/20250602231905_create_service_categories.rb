class CreateServiceCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :service_categories do |t|
      t.references :service_provider, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
