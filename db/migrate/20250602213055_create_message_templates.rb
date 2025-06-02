class CreateMessageTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :message_templates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.string :category

      t.timestamps
    end
  end
end
