class AddServiceBookingForeignKeyToServiceReviews < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :service_reviews, :service_bookings, column: :service_booking_id
  end
end
