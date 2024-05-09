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

ActiveRecord::Schema[7.1].define(version: 2024_05_09_014514) do
  create_table "import_listings", force: :cascade do |t|
    t.integer "import_id"
    t.integer "listing_id"
    t.text "json", limit: 65535
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_import_listings_on_import_id"
    t.index ["listing_id"], name: "index_import_listings_on_listing_id"
  end

  create_table "imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listings", force: :cascade do |t|
    t.integer "external_id"
    t.string "status", default: ""
    t.string "lat"
    t.string "lng"
    t.string "address"
    t.integer "price"
    t.datetime "imported_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "starred", default: false
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.string "external_url"
    t.string "tooltip_photo"
  end

end
