class CreateOriginalityScores < ActiveRecord::Migration[8.0]
  def change
    create_table :originality_scores do |t|
      t.references :listing, null: false, foreign_key: true, index: { unique: true }
      t.integer :overall_score, default: 100
      t.boolean :matching_numbers, default: false
      t.integer :original_paint_pct, default: 100
      t.boolean :original_interior, default: false
      t.text :notes
      t.timestamps
    end
  end
end
