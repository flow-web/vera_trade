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

ActiveRecord::Schema[8.0].define(version: 2025_05_03_060344) do
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

  create_table "listings", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "user_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
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
    t.index ["category_id"], name: "index_vehicles_on_category_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "listings", "users"
  add_foreign_key "listings", "vehicles"
  add_foreign_key "media_folders", "listings"
  add_foreign_key "media_items", "listings"
  add_foreign_key "media_items", "media_folders"
  add_foreign_key "vehicles", "categories"
end
