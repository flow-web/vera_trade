class CreateMediaItems < ActiveRecord::Migration[8.0]
  def change
    create_table :media_items do |t|
      t.string :title
      t.string :context
      t.string :content_type
      t.references :media_folder, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.boolean :private

      t.timestamps
    end
  end
end
