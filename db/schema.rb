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

ActiveRecord::Schema.define(version: 20151126070625) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

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

  create_table "attachments", force: :cascade do |t|
    t.string   "name"
    t.string   "filename"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "bootsy_image_galleries", force: :cascade do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: :cascade do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.string   "chinese_name"
    t.text     "description"
    t.jsonb    "data"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "cartable_id"
    t.string   "cartable_type"
    t.integer  "supplier_id"
    t.string   "title"
    t.string   "image"
    t.integer  "sale_mode",                              default: 0
    t.decimal  "price",         precision: 10, scale: 2
    t.integer  "quantity"
    t.jsonb    "properties",                             default: {}
    t.jsonb    "condition"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "image"
    t.string   "ancestry"
    t.integer  "ancestry_depth",      default: 0
    t.jsonb    "data"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "upper_properties_id"
    t.integer  "brand_id"
  end

  add_index "categories", ["ancestry"], name: "index_categories_on_ancestry", using: :btree

  create_table "categories_properties", id: false, force: :cascade do |t|
    t.integer "category_id",             null: false
    t.integer "property_id",             null: false
    t.integer "state",       default: 0
    t.integer "sortid",      default: 0
  end

  add_index "categories_properties", ["category_id", "property_id"], name: "index_categories_properties_on_category_id_and_property_id", using: :btree
  add_index "categories_properties", ["property_id", "category_id"], name: "index_categories_properties_on_property_id_and_category_id", using: :btree
  add_index "categories_properties", ["state"], name: "index_categories_properties_on_state", using: :btree

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

  create_table "feedbacks", force: :cascade do |t|
    t.string   "name"
    t.string   "mobile"
    t.text     "information"
    t.boolean  "is_show"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "reply"
  end

  create_table "follows", force: :cascade do |t|
    t.integer  "follower_id"
    t.string   "follower_type"
    t.integer  "followable_id"
    t.string   "followable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "industries", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.string   "image"
    t.integer  "status",      default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "category_id"
  end

  create_table "intentions", force: :cascade do |t|
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

  create_table "items", force: :cascade do |t|
    t.integer  "shop_category_id"
    t.integer  "shop_id"
    t.integer  "product_id"
    t.decimal  "price",            precision: 10, scale: 2
    t.integer  "inventory"
    t.boolean  "on_sale",                                   default: true
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "sid"
    t.string   "title"
    t.integer  "category_id"
    t.decimal  "public_price",     precision: 10, scale: 2
    t.decimal  "income_price",     precision: 10, scale: 2
    t.jsonb    "images",                                    default: []
    t.integer  "brand_id"
    t.jsonb    "properties",                                default: {}
    t.text     "description"
    t.decimal  "current_stock",    precision: 10, scale: 2
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "status"
    t.integer  "jobable_id"
    t.string   "jobable_type"
    t.string   "job_type"
    t.jsonb    "input",        default: {}
    t.jsonb    "output",       default: {}
    t.datetime "end_at"
    t.datetime "start_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "likes", force: :cascade do |t|
    t.string   "liker_type"
    t.integer  "liker_id"
    t.string   "likeable_type"
    t.integer  "likeable_id"
    t.datetime "created_at"
  end

  add_index "likes", ["likeable_id", "likeable_type"], name: "fk_likeables", using: :btree
  add_index "likes", ["liker_id", "liker_type"], name: "fk_likes", using: :btree

  create_table "line_items", force: :cascade do |t|
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

  create_table "mentions", force: :cascade do |t|
    t.string   "mentioner_type"
    t.integer  "mentioner_id"
    t.string   "mentionable_type"
    t.integer  "mentionable_id"
    t.datetime "created_at"
  end

  add_index "mentions", ["mentionable_id", "mentionable_type"], name: "fk_mentionables", using: :btree
  add_index "mentions", ["mentioner_id", "mentioner_type"], name: "fk_mentions", using: :btree

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
    t.integer  "order_id"
    t.integer  "orderable_id"
    t.string   "orderable_type"
    t.string   "title",                                                null: false
    t.decimal  "price",          precision: 10, scale: 2
    t.integer  "quantity",                                             null: false
    t.jsonb    "data"
    t.jsonb    "properties",                              default: {}
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["orderable_type", "orderable_id"], name: "index_order_items_on_orderable_type_and_orderable_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer "buyer_id"
    t.integer "supplier_id"
    t.decimal "total",            precision: 10, scale: 2
    t.string  "delivery_address"
    t.boolean "total_modified",                            default: false, null: false
    t.decimal "origin_total",     precision: 10, scale: 2
  end

  add_index "orders", ["buyer_id"], name: "index_orders_on_buyer_id", using: :btree
  add_index "orders", ["supplier_id"], name: "index_orders_on_supplier_id", using: :btree

  create_table "properties", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "summary"
    t.jsonb    "data"
    t.integer  "unit_id"
    t.string   "unit_type"
    t.string   "prop_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "punches", force: :cascade do |t|
    t.integer  "punchable_id",                          null: false
    t.string   "punchable_type", limit: 20,             null: false
    t.datetime "starts_at",                             null: false
    t.datetime "ends_at",                               null: false
    t.datetime "average_time",                          null: false
    t.integer  "hits",                      default: 1, null: false
  end

  add_index "punches", ["average_time"], name: "index_punches_on_average_time", using: :btree
  add_index "punches", ["punchable_type", "punchable_id"], name: "punchable_index", using: :btree

  create_table "shop_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "category_type"
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
    t.string   "title"
    t.integer  "shop_id"
    t.text     "description"
    t.boolean  "status"
  end

  add_index "shop_categories", ["iid"], name: "index_shop_categories_on_iid", using: :btree
  add_index "shop_categories", ["lft"], name: "index_shop_categories_on_lft", using: :btree
  add_index "shop_categories", ["parent_id"], name: "index_shop_categories_on_parent_id", using: :btree
  add_index "shop_categories", ["rgt"], name: "index_shop_categories_on_rgt", using: :btree
  add_index "shop_categories", ["shop_id"], name: "index_shop_categories_on_shop_id", using: :btree

  create_table "shops", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.string   "title"
    t.string   "license_no"
    t.string   "website"
    t.string   "status"
    t.string   "phone"
    t.integer  "industry_id"
    t.text     "description"
    t.string   "provider"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "logo"
    t.string   "address"
    t.jsonb    "settings",    default: {}
  end

  create_table "statuses", force: :cascade do |t|
    t.integer  "stateable_id"
    t.string   "stateable_type"
    t.string   "state"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "stock_changes", force: :cascade do |t|
    t.integer  "item_id",                                                 null: false
    t.decimal  "quantity",       precision: 10, scale: 2,                 null: false
    t.jsonb    "data",                                    default: {}
    t.integer  "unit_id"
    t.integer  "operator_id",                                             null: false
    t.integer  "operation_id"
    t.string   "operation_type"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "is_reset",                                default: false, null: false
    t.integer  "kind",                                                    null: false
  end

  add_index "stock_changes", ["is_reset"], name: "index_stock_changes_on_is_reset", using: :btree
  add_index "stock_changes", ["item_id"], name: "index_stock_changes_on_item_id", using: :btree
  add_index "stock_changes", ["operation_type", "operation_id"], name: "index_stock_changes_on_operation_type_and_operation_id", using: :btree
  add_index "stock_changes", ["operator_id"], name: "index_stock_changes_on_operator_id", using: :btree
  add_index "stock_changes", ["unit_id"], name: "index_stock_changes_on_unit_id", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "condition"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "status",      default: 0
  end

  create_table "templates", force: :cascade do |t|
    t.string   "name"
    t.string   "filename"
    t.integer  "last_editor_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "type"
    t.integer  "templable_id"
    t.string   "templable_type"
    t.boolean  "used",           default: false
  end

  create_table "units", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string   "image",                  default: "", null: false
    t.string   "nickname"
    t.string   "provider"
    t.integer  "latest_location_id"
    t.jsonb    "data",                   default: {}
    t.integer  "sex",                    default: 1
    t.integer  "shop_id"
    t.integer  "user_type",              default: 0
    t.integer  "industry_id"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["data"], name: "index_users_on_data", using: :gin
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "variables", force: :cascade do |t|
    t.string   "name"
    t.string   "data_type"
    t.jsonb    "data"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "host_id"
    t.string   "host_type"
  end

  add_index "variables", ["host_type", "host_id"], name: "index_variables_on_host_type_and_host_id", using: :btree

  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "shops", column: "supplier_id"
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "shop_categories", "shops"
  add_foreign_key "stock_changes", "items"
  add_foreign_key "stock_changes", "units"
  add_foreign_key "stock_changes", "users", column: "operator_id"
end
