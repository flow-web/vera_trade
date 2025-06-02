class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :message
      t.string :notification_type
      t.boolean :read
      t.string :priority
      t.string :action_url
      t.datetime :expires_at
      t.string :related_model
      t.integer :related_id

      t.timestamps
    end
  end
end
