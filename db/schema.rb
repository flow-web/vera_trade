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

ActiveRecord::Schema[8.0].define(version: 2026_04_24_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

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

  create_table "auction_watchers", force: :cascade do |t|
    t.bigint "auction_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id", "user_id"], name: "index_auction_watchers_on_auction_id_and_user_id", unique: true
    t.index ["auction_id"], name: "index_auction_watchers_on_auction_id"
    t.index ["user_id"], name: "index_auction_watchers_on_user_id"
  end

  create_table "auctions", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.decimal "starting_price", precision: 10, scale: 2, null: false
    t.decimal "reserve_price", precision: 10, scale: 2
    t.decimal "current_price", precision: 10, scale: 2
    t.string "status", default: "scheduled", null: false
    t.integer "duration_days", default: 7, null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "bids_count", default: 0, null: false
    t.integer "watchers_count", default: 0, null: false
    t.decimal "seller_fee_pct", precision: 4, scale: 2, default: "5.0", null: false
    t.decimal "buyer_fee_pct", precision: 4, scale: 2, default: "4.5", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ends_at"], name: "index_auctions_on_ends_at"
    t.index ["listing_id"], name: "index_auctions_on_listing_id", unique: true
    t.index ["status"], name: "index_auctions_on_status"
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "auction_id", null: false
    t.bigint "bidder_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.boolean "proxy", default: false, null: false
    t.decimal "max_proxy_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id", "created_at"], name: "index_bids_on_auction_id_and_created_at"
    t.index ["auction_id"], name: "index_bids_on_auction_id"
    t.index ["bidder_id"], name: "index_bids_on_bidder_id"
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
    t.bigint "listing_id"
    t.index ["listing_id", "user_id"], name: "index_conversations_on_listing_and_buyer_unique", unique: true, where: "(listing_id IS NOT NULL)"
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["other_user_id"], name: "index_conversations_on_other_user_id"
    t.index ["updated_at"], name: "index_conversations_on_updated_at"
    t.index ["user_id", "other_user_id"], name: "index_conversations_on_user_id_and_other_user_id", unique: true
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "escrows", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "EUR", null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_transfer_id"
    t.text "notes"
    t.datetime "paid_at"
    t.datetime "released_at"
    t.datetime "disputed_at"
    t.datetime "refunded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_escrows_on_buyer_id"
    t.index ["listing_id"], name: "index_escrows_on_listing_id"
    t.index ["seller_id"], name: "index_escrows_on_seller_id"
    t.index ["status"], name: "index_escrows_on_status"
    t.index ["stripe_payment_intent_id"], name: "index_escrows_on_stripe_payment_intent_id", unique: true, where: "(stripe_payment_intent_id IS NOT NULL)"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_favorites_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_favorites_on_user_id_and_listing_id", unique: true
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

  create_table "kyc_documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "document_type", null: false
    t.string "status", default: "pending", null: false
    t.text "rejection_reason"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_kyc_documents_on_status"
    t.index ["user_id", "document_type"], name: "index_kyc_documents_on_user_id_and_document_type"
    t.index ["user_id"], name: "index_kyc_documents_on_user_id"
  end

  create_table "listing_answers", force: :cascade do |t|
    t.bigint "listing_question_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_question_id"], name: "index_listing_answers_on_listing_question_id", unique: true
    t.index ["user_id"], name: "index_listing_answers_on_user_id"
  end

  create_table "listing_questions", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "published"], name: "index_listing_questions_on_listing_id_and_published"
    t.index ["listing_id"], name: "index_listing_questions_on_listing_id"
    t.index ["user_id"], name: "index_listing_questions_on_user_id"
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
    t.string "slug"
    t.integer "views_count", default: 0, null: false
    t.jsonb "draft_data", default: {}, null: false
    t.integer "wizard_step", default: 0, null: false
    t.datetime "published_at"
    t.index ["buyer_id"], name: "index_listings_on_buyer_id"
    t.index ["description"], name: "index_listings_on_description_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["published_at"], name: "index_listings_on_published_at"
    t.index ["slug"], name: "index_listings_on_slug", unique: true
    t.index ["status"], name: "index_listings_on_status"
    t.index ["title"], name: "index_listings_on_title_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["user_id"], name: "index_listings_on_user_id"
    t.index ["vehicle_id"], name: "index_listings_on_vehicle_id"
    t.index ["wizard_step"], name: "index_listings_on_wizard_step"
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

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false, null: false
    t.bigint "conversation_id"
    t.integer "offer_cents"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["recipient_id", "read"], name: "index_messages_on_recipient_id_and_read"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "originality_scores", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.integer "overall_score", default: 100
    t.boolean "matching_numbers", default: false
    t.integer "original_paint_pct", default: 100
    t.boolean "original_interior", default: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_originality_scores_on_listing_id", unique: true
  end

  create_table "provenance_events", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.integer "event_year", null: false
    t.string "event_type", default: "service", null: false
    t.string "label", null: false
    t.text "description"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_year"], name: "index_provenance_events_on_event_year"
    t.index ["listing_id", "position"], name: "index_provenance_events_on_listing_id_and_position"
    t.index ["listing_id"], name: "index_provenance_events_on_listing_id"
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

  create_table "rust_maps", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.string "silhouette_variant", default: "sedan", null: false
    t.integer "transparency_score", default: 100
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_rust_maps_on_listing_id", unique: true
  end

  create_table "rust_zones", force: :cascade do |t|
    t.bigint "rust_map_id", null: false
    t.decimal "x_pct", precision: 5, scale: 2, null: false
    t.decimal "y_pct", precision: 5, scale: 2, null: false
    t.string "status", default: "ok", null: false
    t.string "label"
    t.text "note"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rust_map_id", "position"], name: "index_rust_zones_on_rust_map_id_and_position"
    t.index ["rust_map_id"], name: "index_rust_zones_on_rust_map_id"
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
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["kyc_status"], name: "index_users_on_kyc_status"
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
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
    t.index ["category_id"], name: "index_vehicles_on_category_id"
    t.index ["created_at"], name: "index_vehicles_on_created_at"
    t.index ["fuel_type"], name: "index_vehicles_on_fuel_type"
    t.index ["license_plate"], name: "index_vehicles_on_license_plate", unique: true
    t.index ["make"], name: "index_vehicles_on_make_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["model"], name: "index_vehicles_on_model_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["transmission"], name: "index_vehicles_on_transmission"
    t.index ["vin"], name: "index_vehicles_on_vin", unique: true
    t.index ["year"], name: "index_vehicles_on_year"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "auction_watchers", "auctions"
  add_foreign_key "auction_watchers", "users"
  add_foreign_key "auctions", "listings"
  add_foreign_key "bids", "auctions"
  add_foreign_key "bids", "users", column: "bidder_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "conversations", "listings"
  add_foreign_key "conversations", "users"
  add_foreign_key "conversations", "users", column: "other_user_id"
  add_foreign_key "escrows", "listings"
  add_foreign_key "escrows", "users", column: "buyer_id"
  add_foreign_key "escrows", "users", column: "seller_id"
  add_foreign_key "favorites", "listings"
  add_foreign_key "favorites", "users"
  add_foreign_key "guest_accounts", "users"
  add_foreign_key "kyc_documents", "users"
  add_foreign_key "kyc_documents", "users", column: "reviewed_by_id"
  add_foreign_key "listing_answers", "listing_questions"
  add_foreign_key "listing_answers", "users"
  add_foreign_key "listing_questions", "listings"
  add_foreign_key "listing_questions", "users"
  add_foreign_key "listings", "users"
  add_foreign_key "listings", "users", column: "buyer_id"
  add_foreign_key "listings", "vehicles"
  add_foreign_key "media_folders", "listings"
  add_foreign_key "media_items", "listings"
  add_foreign_key "media_items", "media_folders"
  add_foreign_key "messages", "conversations"
  add_foreign_key "originality_scores", "listings"
  add_foreign_key "provenance_events", "listings"
  add_foreign_key "reports", "users"
  add_foreign_key "rust_maps", "listings"
  add_foreign_key "rust_zones", "rust_maps"
  add_foreign_key "temporary_listings", "guest_accounts"
  add_foreign_key "temporary_listings", "vehicles"
  add_foreign_key "vehicles", "categories"
  add_foreign_key "wallet_transactions", "wallets"
  add_foreign_key "wallets", "users"
end
