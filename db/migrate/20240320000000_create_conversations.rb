class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :other_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :conversations, [ :user_id, :other_user_id ], unique: true
  end
end
