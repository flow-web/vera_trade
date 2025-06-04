# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_04_203332) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.string "event_type"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "all_day"
    t.string "related_model"
    t.integer "related_id"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.string "slug"
    t.string "icon"
    t.text "description"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "other_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived_by_user"
    t.boolean "archived_by_other_user"
    t.bigint "listing_id", null: false
    t.string "status"
    t.datetime "last_activity_at"
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["other_user_id"], name: "index_conversations_on_other_user_id"
    t.index ["user_id", "other_user_id"], name: "index_conversations_on_user_id_and_other_user_id", unique: true
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "dispute_evidences", force: :cascade do |t|
    t.bigint "dispute_id", null: false
    t.bigint "user_id", null: false
    t.string "evidence_type", null: false
    t.string "title", null: false
    t.text "description"
    t.string "file_type"
    t.bigint "file_size"
    t.string "status", default: "pending_review"
    t.text "review_notes"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_dispute_evidences_on_created_at"
    t.index ["dispute_id", "evidence_type"], name: "index_dispute_evidences_on_dispute_id_and_evidence_type"
    t.index ["dispute_id"], name: "index_dispute_evidences_on_dispute_id"
    t.index ["evidence_type"], name: "index_dispute_evidences_on_evidence_type"
    t.index ["status"], name: "index_dispute_evidences_on_status"
    t.index ["user_id", "dispute_id"], name: "index_dispute_evidences_on_user_id_and_dispute_id"
    t.index ["user_id"], name: "index_dispute_evidences_on_user_id"
  end

  create_table "dispute_messages", force: :cascade do |t|
    t.bigint "dispute_id", null: false
    t.bigint "user_id", null: false
    t.text "message", null: false
    t.string "message_type", default: "user_message"
    t.string "visibility", default: "all_parties"
    t.boolean "read_by_user", default: false
    t.boolean "read_by_other_user", default: false
    t.boolean "read_by_mediator", default: false
    t.datetime "edited_at"
    t.text "edit_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_dispute_messages_on_created_at"
    t.index ["dispute_id", "created_at"], name: "index_dispute_messages_on_dispute_id_and_created_at"
    t.index ["dispute_id"], name: "index_dispute_messages_on_dispute_id"
    t.index ["message_type"], name: "index_dispute_messages_on_message_type"
    t.index ["user_id", "dispute_id"], name: "index_dispute_messages_on_user_id_and_dispute_id"
    t.index ["user_id"], name: "index_dispute_messages_on_user_id"
    t.index ["visibility"], name: "index_dispute_messages_on_visibility"
  end

  create_table "dispute_resolutions", force: :cascade do |t|
    t.bigint "dispute_id", null: false
    t.bigint "proposed_by", null: false
    t.string "resolution_type", null: false
    t.text "details", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.string "status", default: "pending"
    t.text "accepted_by_users"
    t.datetime "expires_at"
    t.datetime "implemented_at"
    t.text "implementation_notes"
    t.text "rejection_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_dispute_resolutions_on_created_at"
    t.index ["dispute_id", "status"], name: "index_dispute_resolutions_on_dispute_id_and_status"
    t.index ["dispute_id"], name: "index_dispute_resolutions_on_dispute_id"
    t.index ["expires_at"], name: "index_dispute_resolutions_on_expires_at"
    t.index ["proposed_by"], name: "index_dispute_resolutions_on_proposed_by"
    t.index ["resolution_type"], name: "index_dispute_resolutions_on_resolution_type"
    t.index ["status"], name: "index_dispute_resolutions_on_status"
  end

  create_table "disputes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "disputed_item_type", null: false
    t.bigint "disputed_item_id", null: false
    t.string "dispute_type", null: false
    t.string "status", default: "open", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.string "priority", default: "normal"
    t.text "resolution"
    t.datetime "resolved_at"
    t.bigint "mediator_id"
    t.datetime "escalated_at"
    t.text "metadata"
    t.string "reference_number"
    t.boolean "auto_resolved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_disputes_on_created_at"
    t.index ["dispute_type"], name: "index_disputes_on_dispute_type"
    t.index ["disputed_item_type", "disputed_item_id"], name: "index_disputes_on_disputed_item"
    t.index ["disputed_item_type", "disputed_item_id"], name: "index_disputes_on_disputed_item_type_and_disputed_item_id"
    t.index ["mediator_id"], name: "index_disputes_on_mediator_id"
    t.index ["priority"], name: "index_disputes_on_priority"
    t.index ["reference_number"], name: "index_disputes_on_reference_number", unique: true
    t.index ["user_id", "status"], name: "index_disputes_on_user_id_and_status"
    t.index ["user_id"], name: "index_disputes_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "favoritable_type"
    t.integer "favoritable_id"
    t.string "name"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "guest_accounts", force: :cascade do |t|
    t.string "email"
    t.string "phone"
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_guest_accounts_on_email"
    t.index ["phone"], name: "index_guest_accounts_on_phone"
    t.index ["token"], name: "index_guest_accounts_on_token", unique: true
    t.index ["user_id"], name: "index_guest_accounts_on_user_id"
  end

  create_table "listings", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "user_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "moderation_status"
    t.text "moderation_reason"
    t.bigint "buyer_id"
    t.boolean "is_certified", default: false
    t.index ["buyer_id"], name: "index_listings_on_buyer_id"
    t.index ["user_id"], name: "index_listings_on_user_id"
    t.index ["vehicle_id"], name: "index_listings_on_vehicle_id"
  end

  create_table "media_folders", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "listing_id", null: false
    t.boolean "private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_media_folders_on_listing_id"
  end

  create_table "media_items", force: :cascade do |t|
    t.string "title"
    t.string "context"
    t.string "content_type"
    t.bigint "media_folder_id", null: false
    t.bigint "listing_id", null: false
    t.boolean "private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_media_items_on_listing_id"
    t.index ["media_folder_id"], name: "index_media_items_on_media_folder_id"
  end

  create_table "message_templates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "content"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_message_templates_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false, null: false
    t.string "status"
    t.string "message_type"
    t.datetime "read_at"
    t.text "attachment_data"
    t.text "reactions"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "message"
    t.string "notification_type"
    t.boolean "read"
    t.string "priority"
    t.string "action_url"
    t.datetime "expires_at"
    t.string "related_model"
    t.integer "related_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "reason"
    t.string "status"
    t.string "reportable_type", null: false
    t.bigint "reportable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "service_bookings", force: :cascade do |t|
    t.bigint "service_provider_id", null: false
    t.bigint "user_id", null: false
    t.bigint "service_offer_id", null: false
    t.bigint "listing_id", null: false
    t.text "description"
    t.date "proposed_date"
    t.decimal "total_amount"
    t.integer "status"
    t.integer "payment_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_service_bookings_on_listing_id"
    t.index ["service_offer_id"], name: "index_service_bookings_on_service_offer_id"
    t.index ["service_provider_id"], name: "index_service_bookings_on_service_provider_id"
    t.index ["user_id"], name: "index_service_bookings_on_user_id"
  end

  create_table "service_categories", force: :cascade do |t|
    t.bigint "service_provider_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_service_categories_on_category_id"
    t.index ["service_provider_id"], name: "index_service_categories_on_service_provider_id"
  end

  create_table "service_offers", force: :cascade do |t|
    t.bigint "service_provider_id", null: false
    t.bigint "category_id", null: false
    t.string "title"
    t.text "description"
    t.integer "pricing_type"
    t.decimal "base_price"
    t.string "duration_estimate"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_service_offers_on_category_id"
    t.index ["service_provider_id"], name: "index_service_offers_on_service_provider_id"
  end

  create_table "service_providers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name"
    t.text "description"
    t.string "phone"
    t.text "address"
    t.string "city"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.text "specialties"
    t.string "website"
    t.integer "status"
    t.integer "verification_status"
    t.decimal "average_rating"
    t.integer "total_reviews"
    t.datetime "suspended_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_service_providers_on_user_id"
  end

  create_table "service_request_responses", force: :cascade do |t|
    t.bigint "service_request_id", null: false
    t.bigint "service_provider_id", null: false
    t.text "message"
    t.decimal "proposed_price"
    t.string "estimated_duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_provider_id"], name: "index_service_request_responses_on_service_provider_id"
    t.index ["service_request_id"], name: "index_service_request_responses_on_service_request_id"
  end

  create_table "service_requests", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "title"
    t.text "description"
    t.decimal "budget_min"
    t.decimal "budget_max"
    t.date "deadline"
    t.integer "status"
    t.integer "urgency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_service_requests_on_category_id"
    t.index ["listing_id"], name: "index_service_requests_on_listing_id"
    t.index ["user_id"], name: "index_service_requests_on_user_id"
  end

  create_table "service_reviews", force: :cascade do |t|
    t.bigint "service_provider_id", null: false
    t.bigint "user_id", null: false
    t.integer "service_booking_id"
    t.integer "rating"
    t.string "title"
    t.text "comment"
    t.integer "communication_rating"
    t.integer "quality_rating"
    t.integer "value_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_provider_id"], name: "index_service_reviews_on_service_provider_id"
    t.index ["user_id"], name: "index_service_reviews_on_user_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "priority", default: "normal"
    t.string "status", default: "open", null: false
    t.string "category", null: false
    t.bigint "assigned_to"
    t.string "ticket_number"
    t.text "tags"
    t.datetime "resolved_at"
    t.text "resolution_notes"
    t.decimal "satisfaction_rating", precision: 3, scale: 2
    t.text "satisfaction_feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to"], name: "index_support_tickets_on_assigned_to"
    t.index ["category"], name: "index_support_tickets_on_category"
    t.index ["created_at"], name: "index_support_tickets_on_created_at"
    t.index ["priority"], name: "index_support_tickets_on_priority"
    t.index ["ticket_number"], name: "index_support_tickets_on_ticket_number", unique: true
    t.index ["user_id", "status"], name: "index_support_tickets_on_user_id_and_status"
    t.index ["user_id"], name: "index_support_tickets_on_user_id"
  end

  create_table "temporary_listings", force: :cascade do |t|
    t.bigint "guest_account_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "title"
    t.text "description"
    t.string "status", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guest_account_id"], name: "index_temporary_listings_on_guest_account_id"
    t.index ["vehicle_id"], name: "index_temporary_listings_on_vehicle_id"
  end

  create_table "ticket_messages", force: :cascade do |t|
    t.bigint "support_ticket_id", null: false
    t.bigint "user_id", null: false
    t.text "message", null: false
    t.string "message_type", default: "user_message"
    t.boolean "internal", default: false
    t.boolean "read_by_user", default: false
    t.boolean "read_by_admin", default: false
    t.datetime "edited_at"
    t.text "edit_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_ticket_messages_on_created_at"
    t.index ["internal"], name: "index_ticket_messages_on_internal"
    t.index ["message_type"], name: "index_ticket_messages_on_message_type"
    t.index ["support_ticket_id", "created_at"], name: "index_ticket_messages_on_support_ticket_id_and_created_at"
    t.index ["support_ticket_id"], name: "index_ticket_messages_on_support_ticket_id"
    t.index ["user_id", "support_ticket_id"], name: "index_ticket_messages_on_user_id_and_support_ticket_id"
    t.index ["user_id"], name: "index_ticket_messages_on_user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "profile_type"
    t.boolean "is_main"
    t.text "permissions"
    t.string "name"
    t.string "position"
    t.string "department"
    t.string "access_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "avatar_url"
    t.integer "role"
    t.string "kyc_status"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "image"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "make"
    t.string "model"
    t.integer "year"
    t.text "description"
    t.decimal "price"
    t.integer "kilometers"
    t.string "fuel_type"
    t.string "transmission"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "finition"
    t.integer "doors"
    t.string "exterior_color"
    t.string "interior_material"
    t.string "interior_color"
    t.integer "previous_owners"
    t.date "last_service_date"
    t.date "next_ct_date"
    t.date "ct_expiry_date"
    t.boolean "has_service_history"
    t.boolean "non_smoker"
    t.string "location"
    t.text "safety_features"
    t.text "comfort_features"
    t.text "multimedia_features"
    t.text "exterior_features"
    t.text "other_features"
    t.text "body_condition"
    t.text "interior_condition"
    t.text "tire_condition"
    t.text "recent_works"
    t.text "issues"
    t.text "expected_costs"
    t.bigint "category_id"
    t.string "subcategory"
    t.string "custom_type"
    t.integer "cylinder_capacity"
    t.string "engine_type"
    t.string "cooling_type"
    t.string "starter_type"
    t.string "license_type"
    t.decimal "length", precision: 10, scale: 2
    t.decimal "width", precision: 10, scale: 2
    t.decimal "draft", precision: 10, scale: 2
    t.string "hull_material"
    t.integer "number_of_cabins"
    t.integer "number_of_berths"
    t.integer "engine_hours"
    t.string "drive_type"
    t.string "transmission_type"
    t.integer "number_of_seats"
    t.integer "flight_hours"
    t.integer "number_of_engines"
    t.integer "ceiling"
    t.integer "range"
    t.integer "operating_hours"
    t.decimal "lifting_capacity", precision: 10, scale: 2
    t.decimal "maximum_reach", precision: 10, scale: 2
    t.text "additional_equipment"
    t.decimal "bucket_capacity", precision: 10, scale: 2
    t.decimal "loading_capacity", precision: 10, scale: 2
    t.decimal "towing_capacity", precision: 10, scale: 2
    t.integer "axles"
    t.boolean "sleeping_cab"
    t.string "emission_standard"
    t.string "registration"
    t.string "vin"
    t.string "license_plate"
    t.integer "fiscal_power"
    t.decimal "average_consumption", precision: 5, scale: 2
    t.integer "co2_emissions"
    t.boolean "is_draft", default: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.text "address"
    t.index ["category_id"], name: "index_vehicles_on_category_id"
    t.index ["latitude", "longitude"], name: "index_vehicles_on_latitude_and_longitude"
    t.index ["license_plate"], name: "index_vehicles_on_license_plate", unique: true
    t.index ["vin"], name: "index_vehicles_on_vin", unique: true
  end

  create_table "video_calls", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "status"
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "recording_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "room_id"
    t.index ["conversation_id"], name: "index_video_calls_on_conversation_id"
  end

  create_table "wallet_transactions", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "EUR", null: false
    t.integer "transaction_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "reference"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_wallet_transactions_on_reference"
    t.index ["status"], name: "index_wallet_transactions_on_status"
    t.index ["transaction_type"], name: "index_wallet_transactions_on_transaction_type"
    t.index ["wallet_id"], name: "index_wallet_transactions_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "balance_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "conversations", "listings"
  add_foreign_key "conversations", "users"
  add_foreign_key "conversations", "users", column: "other_user_id"
  add_foreign_key "dispute_evidences", "disputes"
  add_foreign_key "dispute_evidences", "users"
  add_foreign_key "dispute_evidences", "users", column: "reviewed_by"
  add_foreign_key "dispute_messages", "disputes"
  add_foreign_key "dispute_messages", "users"
  add_foreign_key "dispute_resolutions", "disputes"
  add_foreign_key "dispute_resolutions", "users", column: "proposed_by"
  add_foreign_key "disputes", "users"
  add_foreign_key "disputes", "users", column: "mediator_id"
  add_foreign_key "events", "users"
  add_foreign_key "favorites", "users"
  add_foreign_key "guest_accounts", "users"
  add_foreign_key "listings", "users"
  add_foreign_key "listings", "users", column: "buyer_id"
  add_foreign_key "listings", "vehicles"
  add_foreign_key "media_folders", "listings"
  add_foreign_key "media_items", "listings"
  add_foreign_key "media_items", "media_folders"
  add_foreign_key "message_templates", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "service_bookings", "listings"
  add_foreign_key "service_bookings", "service_offers"
  add_foreign_key "service_bookings", "service_providers"
  add_foreign_key "service_bookings", "users"
  add_foreign_key "service_categories", "categories"
  add_foreign_key "service_categories", "service_providers"
  add_foreign_key "service_offers", "categories"
  add_foreign_key "service_offers", "service_providers"
  add_foreign_key "service_providers", "users"
  add_foreign_key "service_request_responses", "service_providers"
  add_foreign_key "service_request_responses", "service_requests"
  add_foreign_key "service_requests", "categories"
  add_foreign_key "service_requests", "listings"
  add_foreign_key "service_requests", "users"
  add_foreign_key "service_reviews", "service_bookings"
  add_foreign_key "service_reviews", "service_providers"
  add_foreign_key "service_reviews", "users"
  add_foreign_key "support_tickets", "users"
  add_foreign_key "support_tickets", "users", column: "assigned_to"
  add_foreign_key "temporary_listings", "guest_accounts"
  add_foreign_key "temporary_listings", "vehicles"
  add_foreign_key "ticket_messages", "support_tickets"
  add_foreign_key "ticket_messages", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "vehicles", "categories"
  add_foreign_key "video_calls", "conversations"
  add_foreign_key "wallet_transactions", "wallets"
  add_foreign_key "wallets", "users"
end
