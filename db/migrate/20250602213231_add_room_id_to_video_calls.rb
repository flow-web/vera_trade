class AddRoomIdToVideoCalls < ActiveRecord::Migration[8.0]
  def change
    add_column :video_calls, :room_id, :string
  end
end
