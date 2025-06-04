class CreateVideoCalls < ActiveRecord::Migration[8.0]
  def change
    create_table :video_calls do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :status
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :ended_at
      t.string :recording_url

      t.timestamps
    end
  end
end
