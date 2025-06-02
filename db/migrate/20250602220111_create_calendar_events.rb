class CreateCalendarEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :event_type
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :all_day
      t.string :related_model
      t.integer :related_id
      t.string :color

      t.timestamps
    end
  end
end
