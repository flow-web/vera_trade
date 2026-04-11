class CreateListingQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_questions do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :published, default: false
      t.timestamps
    end
    add_index :listing_questions, [:listing_id, :published]
  end
end
