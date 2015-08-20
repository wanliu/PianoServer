# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150819094158) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "iid"
    t.integer  "parent_id"
    t.integer  "lft",                        null: false
    t.integer  "rgt",                        null: false
    t.integer  "depth",          default: 0, null: false
    t.integer  "children_count", default: 0, null: false
    t.integer  "position"
    t.jsonb    "data"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "image"
  end

  add_index "categories", ["iid"], name: "index_categories_on_iid", using: :btree
  add_index "categories", ["lft"], name: "index_categories_on_lft", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["rgt"], name: "index_categories_on_rgt", using: :btree

  create_table "categories_shops", id: false, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "shop_id",     null: false
  end

  create_table "chats", force: :cascade do |t|
    t.integer  "chatable_id"
    t.string   "chatable_type"
    t.string   "name"
    t.integer  "target_id"
    t.integer  "owner_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.jsonb    "data",          default: {}, null: false
    t.string   "channel_id"
    t.string   "tokens",                                  array: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "mobile"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer  "shop_category_id"
    t.integer  "shop_id"
    t.integer  "product_id"
    t.decimal  "price",            precision: 10, scale: 2
    t.integer  "inventory"
    t.boolean  "on_sale",                                   default: true
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "province_id"
    t.integer  "city_id"
    t.integer  "region_id"
    t.string   "road"
    t.string   "zipcode"
    t.string   "contact"
    t.string   "contact_phone"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "logs", force: :cascade do |t|
    t.integer  "loggable_id"
    t.string   "loggable_type"
    t.integer  "operator_id"
    t.jsonb    "data",          default: {}, null: false
    t.string   "action"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "messable_id"
    t.string   "messable_type"
    t.text     "text"
    t.string   "type"
    t.integer  "from_id"
    t.integer  "reply_id"
    t.jsonb    "mentions",      default: {},    null: false
    t.boolean  "read",          default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "image_ref_id"
    t.jsonb    "image",         default: {},    null: false
  end

  create_table "notifies", force: :cascade do |t|
    t.integer  "notifiable_id"
    t.integer  "user_id"
    t.string   "text"
    t.string   "target"
    t.string   "type"
    t.jsonb    "image",         default: {},    null: false
    t.jsonb    "data",          default: {},    null: false
    t.boolean  "read",          default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "itemable_id"
    t.string   "itemable_type"
    t.string   "title"
    t.jsonb    "data",                                   default: {}, null: false
    t.integer  "iid"
    t.string   "item_type"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.jsonb    "image",                                  default: {}, null: false
    t.decimal  "price",         precision: 15, scale: 2
    t.decimal  "amount",        precision: 15, scale: 8
    t.decimal  "sub_total",     precision: 16, scale: 2
    t.integer  "unit"
    t.string   "unit_title"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "supplier_id"
    t.string   "contacts"
    t.integer  "business_type"
    t.integer  "bid"
    t.integer  "sid"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "title"
    t.decimal  "total",                precision: 18, scale: 2
    t.jsonb    "image"
    t.jsonb    "data"
    t.integer  "delivery_location_id"
    t.integer  "send_location_id"
  end

  create_table "shops", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.string   "title"
    t.string   "license_no"
    t.string   "website"
    t.string   "status"
    t.integer  "location_id"
    t.string   "phone"
    t.integer  "industry_id"
    t.jsonb    "image"
    t.text     "description"
    t.string   "provider"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.integer  "stateable_id"
    t.string   "stateable_type"
    t.integer  "state"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mobile"
    t.string   "username"
    t.string   "authentication_token"
    t.jsonb    "image",                  default: {}, null: false
    t.string   "nickname"
    t.string   "provider"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
