class FixMessagesFkAndNullability < ActiveRecord::Migration[8.0]
  def up
    Message.where(sender_id: nil).or(Message.where(recipient_id: nil)).delete_all

    change_column_null :messages, :sender_id, false
    change_column_null :messages, :recipient_id, false
  end

  def down
    change_column_null :messages, :sender_id, true
    change_column_null :messages, :recipient_id, true
  end
end
