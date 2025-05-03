class CreateMediaFolders < ActiveRecord::Migration[8.0]
  def change
    create_table :media_folders do |t|
      t.string :name
      t.text :description
      t.references :listing, null: false, foreign_key: true
      t.boolean :private

      t.timestamps
    end
  end
end
