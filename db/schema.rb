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

ActiveRecord::Schema.define(version: 20170730021731) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  
  create_table "attachments", force: :cascade do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type",         limit: 255
    t.string   "description",             limit: 255
    t.string   "locale",                  limit: 255, default: "en", null: false
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brand_profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "industry",     limit: 255,                              array: true
    t.text     "idea"
    t.text     "overall_look"
    t.text     "your_brand"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",         limit: 255
    t.integer  "brand_id"
    t.boolean  "use_brand",                default: false, null: false
    t.string   "slug",         limit: 255
  end

  add_index "brand_profiles", ["slug"], name: "index_brand_profiles_on_slug", unique: true, using: :btree

  create_table "brands", force: :cascade do |t|
    t.string   "title",                     limit: 255
    t.text     "description"
    t.string   "currency",                  limit: 255
    t.integer  "employee_count"
    t.integer  "year_founded"
    t.integer  "max_budget_cents",                      default: 0,     null: false
    t.integer  "prices_from_cents"
    t.integer  "prices_to_cents"
    t.string   "slug",                      limit: 255
    t.string   "image_file_name",           limit: 255
    t.string   "image_content_type",        limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags",                      limit: 255,                              array: true
    t.boolean  "is_premium",                            default: false, null: false
    t.datetime "valid_until"
    t.datetime "reminder_sent_at"
    t.string   "logo_file_name",            limit: 255
    t.string   "logo_content_type",         limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "twitter_id",                limit: 255
    t.string   "facebook_id",               limit: 255
    t.string   "instagram_id",              limit: 255
    t.string   "name",                      limit: 255
    t.string   "based",                     limit: 255
    t.string   "website",                   limit: 255
    t.string   "gender",                    limit: 255
    t.string   "firstname",                 limit: 255
    t.string   "lastname",                  limit: 255
    t.string   "jobtitle",                  limit: 255
    t.string   "email",                     limit: 255
    t.boolean  "imported"
    t.boolean  "interested_collaborations"
    t.boolean  "looking_for_space"
    t.string   "folder",                    limit: 255
    t.string   "tagline",                   limit: 255
    t.text     "idea"
    t.string   "industry",                  limit: 255, default: [],                 array: true
    t.text     "overall_look"
    t.boolean  "is_deleted",                            default: false, null: false
  end

  add_index "brands", ["slug"], name: "index_brands_on_slug", unique: true, using: :btree
  add_index "brands", ["title"], name: "index_brands_on_title", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "company",                limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "address_1",              limit: 255
    t.string   "address_2",              limit: 255
    t.string   "zip",                    limit: 255
    t.string   "city",                   limit: 255
    t.string   "phone",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.boolean  "is_active",                          default: true,  null: false
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "description",            limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "payout_method",          limit: 255
    t.boolean  "is_admin",                           default: false
    t.string   "gender",                 limit: 255
    t.string   "locale",                 limit: 255
    t.integer  "payout_country_id"
    t.string   "payout_payee_name",      limit: 255
    t.string   "payout_iban",            limit: 255
    t.string   "payout_bic",             limit: 255
    t.string   "payout_reference",       limit: 255
    t.string   "payout_paypal_email",    limit: 255
    t.string   "payout_currency",        limit: 255
    t.boolean  "notify_offers",                      default: true,  null: false
    t.boolean  "notify_news",                        default: true,  null: false
    t.boolean  "notify_upcoming",                    default: true,  null: false
    t.boolean  "notify_improve",                     default: true,  null: false
    t.integer  "country_id"
    t.string   "currency",               limit: 255
    t.string   "cancellation_policy",    limit: 255
    t.string   "languages",              limit: 255,                              array: true
    t.integer  "zendesk_id",             limit: 8
    t.string   "company_no",             limit: 255
    t.string   "vat_no",                 limit: 255
    t.boolean  "id_verified",                        default: false
    t.boolean  "phone_verified",                     default: false
    t.string   "id_photo_file_name",     limit: 255
    t.string   "id_photo_content_type",  limit: 255
    t.integer  "id_photo_file_size"
    t.datetime "id_photo_updated_at"
    t.datetime "mailchimp_updated_at"
    t.string   "industry",               limit: 255,                              array: true
    t.string   "memberships",            limit: 255, default: [],                 array: true
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
