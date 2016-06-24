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

ActiveRecord::Schema.define(version: 20160624023212) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "cube"
  enable_extension "earthdistance"

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

  create_table "birthday_parties", force: :cascade do |t|
    t.integer  "cake_id"
    t.integer  "user_id"
    t.integer  "order_id"
    t.integer  "hearts_limit"
    t.date     "birth_day"
    t.string   "birthday_person"
    t.string   "person_avatar"
    t.text     "message"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.decimal  "withdrew",        precision: 10, scale: 2, default: 0.0
    t.integer  "lock_version",                             default: 0
  end

  add_index "birthday_parties", ["cake_id"], name: "index_birthday_parties_on_cake_id", using: :btree
  add_index "birthday_parties", ["order_id"], name: "index_birthday_parties_on_order_id", using: :btree
  add_index "birthday_parties", ["user_id"], name: "index_birthday_parties_on_user_id", using: :btree

  create_table "blesses", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "virtual_present_id"
    t.text     "message"
    t.integer  "birthday_party_id"
    t.boolean  "paid"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "blesses", ["birthday_party_id"], name: "index_blesses_on_birthday_party_id", using: :btree
  add_index "blesses", ["virtual_present_id"], name: "index_blesses_on_virtual_present_id", using: :btree

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

  create_table "cakes", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "hearts_limit"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "cakes", ["item_id"], name: "index_cakes_on_item_id", using: :btree

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

  create_table "coupon_template_shops", force: :cascade do |t|
    t.integer  "coupon_template_id"
    t.integer  "shop_id"
    t.integer  "kind"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "coupon_template_shops", ["coupon_template_id"], name: "index_coupon_template_shops_on_coupon_template_id", using: :btree
  add_index "coupon_template_shops", ["kind"], name: "index_coupon_template_shops_on_kind", using: :btree
  add_index "coupon_template_shops", ["shop_id"], name: "index_coupon_template_shops_on_shop_id", using: :btree

  create_table "coupon_template_times", force: :cascade do |t|
    t.integer  "coupon_template_id"
    t.integer  "type"
    t.datetime "from"
    t.datetime "to"
    t.jsonb    "expire_duration",    default: {}
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "coupon_template_times", ["coupon_template_id"], name: "index_coupon_template_times_on_coupon_template_id", using: :btree

  create_table "coupon_templates", force: :cascade do |t|
    t.integer  "issuer_id"
    t.string   "issuer_type"
    t.string   "name"
    t.decimal  "par",                 precision: 10, scale: 2
    t.integer  "apply_items"
    t.decimal  "apply_minimal_total", precision: 10, scale: 2
    t.integer  "apply_shops"
    t.integer  "apply_time"
    t.boolean  "overlap"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "coupons_count"
    t.text     "desc"
    t.boolean  "issued",                                       default: false
  end

  add_index "coupon_templates", ["issuer_type", "issuer_id"], name: "index_coupon_templates_on_issuer_type_and_issuer_id", using: :btree

  create_table "coupon_tokens", force: :cascade do |t|
    t.integer  "coupon_template_id"
    t.integer  "customer_id"
    t.string   "token"
    t.integer  "lock_version",       default: 0
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "coupon_tokens", ["coupon_template_id"], name: "index_coupon_tokens_on_coupon_template_id", using: :btree
  add_index "coupon_tokens", ["customer_id"], name: "index_coupon_tokens_on_customer_id", using: :btree
  add_index "coupon_tokens", ["token"], name: "index_coupon_tokens_on_token", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.integer  "coupon_template_id"
    t.integer  "receiver_shop_id"
    t.datetime "receive_time"
    t.integer  "receive_taget_id"
    t.string   "receive_taget_type"
    t.integer  "customer_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "status",                                      default: 0
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "lock_version",                                default: 0
    t.datetime "deleted_at"
    t.decimal  "offset_par",         precision: 10, scale: 2, default: 0.0
  end

  add_index "coupons", ["coupon_template_id"], name: "index_coupons_on_coupon_template_id", using: :btree
  add_index "coupons", ["customer_id"], name: "index_coupons_on_customer_id", using: :btree
  add_index "coupons", ["deleted_at"], name: "index_coupons_on_deleted_at", using: :btree
  add_index "coupons", ["receive_taget_type", "receive_taget_id"], name: "index_coupons_on_receive_taget_type_and_receive_taget_id", using: :btree
  add_index "coupons", ["receiver_shop_id"], name: "index_coupons_on_receiver_shop_id", using: :btree

  create_table "evaluations", force: :cascade do |t|
    t.integer  "evaluationable_id"
    t.string   "evaluationable_type"
    t.integer  "user_id"
    t.integer  "order_id"
    t.boolean  "hidden",              default: false
    t.string   "desc"
    t.jsonb    "items",               default: {}
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "evaluations", ["evaluationable_type", "evaluationable_id"], name: "index_evaluations_on_evaluationable_type_and_evaluationable_id", using: :btree
  add_index "evaluations", ["order_id"], name: "index_evaluations_on_order_id", using: :btree
  add_index "evaluations", ["user_id"], name: "index_evaluations_on_user_id", using: :btree

  create_table "express_templates", force: :cascade do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.boolean  "free_shipping", default: false
    t.jsonb    "template",      default: {}
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "express_templates", ["shop_id"], name: "index_express_templates_on_shop_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "favoritor_id"
    t.string   "favoritor_type"
    t.integer  "favoritable_id"
    t.string   "favoritable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "favorites", ["favoritable_type", "favoritable_id"], name: "index_favorites_on_favoritable_type_and_favoritable_id", using: :btree
  add_index "favorites", ["favoritor_type", "favoritor_id"], name: "index_favorites_on_favoritor_type_and_favoritor_id", using: :btree

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

  create_table "gifts", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "present_id"
    t.integer  "quantity"
    t.integer  "total"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "saled_counter", default: 0
    t.jsonb    "properties",    default: {}
  end

  add_index "gifts", ["item_id"], name: "index_gifts_on_item_id", using: :btree
  add_index "gifts", ["present_id"], name: "index_gifts_on_present_id", using: :btree

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
    t.decimal  "price",               precision: 10, scale: 2
    t.integer  "inventory"
    t.boolean  "on_sale",                                      default: true
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "sid"
    t.string   "title"
    t.integer  "category_id"
    t.decimal  "public_price",        precision: 10, scale: 2
    t.decimal  "income_price",        precision: 10, scale: 2
    t.jsonb    "images",                                       default: []
    t.integer  "brand_id"
    t.jsonb    "properties",                                   default: {}
    t.text     "description"
    t.decimal  "current_stock",       precision: 10, scale: 2
    t.boolean  "abandom",                                      default: false, null: false
    t.jsonb    "properties_setting",                           default: {}
    t.integer  "express_template_id"
  end

  add_index "items", ["brand_id"], name: "index_items_on_brand_id", using: :btree
  add_index "items", ["category_id"], name: "index_items_on_category_id", using: :btree
  add_index "items", ["on_sale"], name: "index_items_on_on_sale", using: :btree
  add_index "items", ["shop_category_id"], name: "index_items_on_shop_category_id", using: :btree
  add_index "items", ["shop_id"], name: "index_items_on_shop_id", using: :btree
  add_index "items", ["sid"], name: "index_items_on_sid", using: :btree

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
    t.jsonb    "gifts",                                   default: {}
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["orderable_type", "orderable_id"], name: "index_order_items_on_orderable_type_and_orderable_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "supplier_id"
    t.decimal  "total",             precision: 10, scale: 2
    t.string   "delivery_address"
    t.boolean  "total_modified",                             default: false, null: false
    t.decimal  "origin_total",      precision: 10, scale: 2
    t.integer  "status",                                     default: 0
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "receiver_name"
    t.string   "receiver_phone"
    t.integer  "pmo_grab_id"
    t.integer  "one_money_id"
    t.decimal  "express_fee",       precision: 10, scale: 2, default: 0.0
    t.boolean  "paid",                                       default: false
    t.string   "wx_prepay_id"
    t.string   "wx_noncestr"
    t.string   "wx_transaction_id"
    t.decimal  "paid_total",        precision: 10, scale: 2
    t.string   "note"
    t.string   "receive_token"
    t.decimal  "offseted_total",    precision: 10, scale: 2, default: 0.0
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

  create_table "redpacks", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "amount",            precision: 10, scale: 2
    t.integer  "birthday_party_id"
    t.string   "nonce_str"
    t.string   "wx_order_no"
    t.boolean  "sent"
    t.boolean  "withdrew",                                   default: false
    t.string   "wx_user_openid"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  add_index "redpacks", ["birthday_party_id"], name: "index_redpacks_on_birthday_party_id", using: :btree
  add_index "redpacks", ["sent"], name: "index_redpacks_on_sent", using: :btree
  add_index "redpacks", ["user_id"], name: "index_redpacks_on_user_id", using: :btree
  add_index "redpacks", ["withdrew"], name: "index_redpacks_on_withdrew", using: :btree
  add_index "redpacks", ["wx_order_no"], name: "index_redpacks_on_wx_order_no", using: :btree
  add_index "redpacks", ["wx_user_openid"], name: "index_redpacks_on_wx_user_openid", using: :btree

  create_table "regions", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "city_id"
    t.jsonb    "data",           default: {}
    t.integer  "parent_id"
    t.integer  "lft",                         null: false
    t.integer  "rgt",                         null: false
    t.integer  "depth",          default: 0,  null: false
    t.integer  "children_count", default: 0,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "regions", ["lft"], name: "index_regions_on_lft", using: :btree
  add_index "regions", ["parent_id"], name: "index_regions_on_parent_id", using: :btree
  add_index "regions", ["rgt"], name: "index_regions_on_rgt", using: :btree

  create_table "shop_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "category_type"
    t.integer  "iid"
    t.integer  "parent_id"
    t.integer  "lft",                           null: false
    t.integer  "rgt",                           null: false
    t.integer  "depth",          default: 0,    null: false
    t.integer  "children_count", default: 0,    null: false
    t.integer  "position"
    t.jsonb    "data"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "image"
    t.string   "title"
    t.integer  "shop_id"
    t.text     "description"
    t.boolean  "status",         default: true
  end

  add_index "shop_categories", ["iid"], name: "index_shop_categories_on_iid", using: :btree
  add_index "shop_categories", ["lft"], name: "index_shop_categories_on_lft", using: :btree
  add_index "shop_categories", ["parent_id"], name: "index_shop_categories_on_parent_id", using: :btree
  add_index "shop_categories", ["rgt"], name: "index_shop_categories_on_rgt", using: :btree
  add_index "shop_categories", ["shop_id"], name: "index_shop_categories_on_shop_id", using: :btree

  create_table "shop_delivers", force: :cascade do |t|
    t.integer  "shop_id"
    t.integer  "deliver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shop_delivers", ["deliver_id"], name: "index_shop_delivers_on_deliver_id", using: :btree
  add_index "shop_delivers", ["shop_id"], name: "index_shop_delivers_on_shop_id", using: :btree

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
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "logo"
    t.jsonb    "settings",                    default: {}
    t.string   "address"
    t.integer  "shop_type",                   default: 0
    t.float    "lat"
    t.float    "lon"
    t.integer  "location_id"
    t.string   "region_id"
    t.integer  "default_express_template_id"
  end

  add_index "shops", ["name"], name: "index_shops_on_name", using: :btree
  add_index "shops", ["owner_id"], name: "index_shops_on_owner_id", using: :btree
  add_index "shops", ["title"], name: "index_shops_on_title", using: :btree

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

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

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

  create_table "thumbs", force: :cascade do |t|
    t.integer  "thumber_id"
    t.integer  "thumbable_id"
    t.string   "thumbable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "thumbs", ["thumbable_type", "thumbable_id"], name: "index_thumbs_on_thumbable_type_and_thumbable_id", using: :btree
  add_index "thumbs", ["thumber_id"], name: "index_thumbs_on_thumber_id", using: :btree

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
    t.string   "image",                  default: ""
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
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
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

  create_table "virtual_presents", force: :cascade do |t|
    t.decimal  "price",      precision: 10, scale: 2
    t.string   "name"
    t.boolean  "show",                                default: true
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.decimal  "value",                               default: 0.0
    t.string   "title"
  end

  add_index "virtual_presents", ["show"], name: "index_virtual_presents_on_show", using: :btree

  add_foreign_key "gifts", "items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "shops", column: "supplier_id"
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "shop_categories", "shops"
  add_foreign_key "shop_delivers", "shops"
  add_foreign_key "shop_delivers", "users", column: "deliver_id"
  add_foreign_key "stock_changes", "items"
  add_foreign_key "stock_changes", "units"
  add_foreign_key "stock_changes", "users", column: "operator_id"
  add_foreign_key "thumbs", "users", column: "thumber_id"
end
