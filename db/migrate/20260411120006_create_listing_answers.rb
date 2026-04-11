class CreateListingAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_answers do |t|
      t.references :listing_question, null: false, foreign_key: true, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
