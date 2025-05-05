class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.text :reason
      t.string :status
      t.references :reportable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
