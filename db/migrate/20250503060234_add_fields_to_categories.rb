class AddFieldsToCategories < ActiveRecord::Migration[8.0]
  def change
    add_reference :categories, :parent, foreign_key: { to_table: :categories }
    add_column :categories, :slug, :string
    add_column :categories, :icon, :string
    add_column :categories, :description, :text
    add_index :categories, :slug, unique: true
  end
end 