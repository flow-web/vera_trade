class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :profile_type
      t.boolean :is_main
      t.text :permissions
      t.string :name
      t.string :position
      t.string :department
      t.string :access_level

      t.timestamps
    end
  end
end
