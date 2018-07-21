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

ActiveRecord::Schema.define(version: 20180629030441) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "id_card_import_file_transitions", force: :cascade do |t|
    t.string   "to_state"
    t.string   "metadata"
    t.integer  "sort_key"
    t.integer  "id_card_import_file_id"
    t.boolean  "most_recent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "id_card_import_files", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.text     "note"
    t.datetime "executed_at"
    t.string   "id_card_import_file_name"
    t.string   "id_card_import_content_type"
    t.integer  "id_card_import_file_size"
    t.datetime "id_card_import_updated_at"
    t.string   "id_card_import_fingerprint"
    t.string   "edit_mode"
    t.text     "error_message"
    t.string   "user_encoding"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "id_card_import_results", force: :cascade do |t|
    t.integer  "id_card_import_file_id"
    t.integer  "self_iccard_id"
    t.text     "body"
    t.text     "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "id_card_import_results", ["id_card_import_file_id"], name: "index_id_card_import_results_on_id_card_import_file_id", using: :btree
  add_index "id_card_import_results", ["self_iccard_id"], name: "index_id_card_import_results_on_self_iccard_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.integer  "profile_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "provider"
  end

  add_index "identities", ["email"], name: "index_identities_on_email", using: :btree
  add_index "identities", ["name"], name: "index_identities_on_name", using: :btree
  add_index "identities", ["profile_id"], name: "index_identities_on_profile_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_group_id"
    t.integer  "library_id"
    t.string   "locale"
    t.string   "user_number"
    t.text     "full_name"
    t.text     "note"
    t.text     "keyword_list"
    t.integer  "required_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expired_at"
    t.text     "full_name_transcription"
    t.datetime "date_of_birth"
  end

  add_index "profiles", ["library_id"], name: "index_profiles_on_library_id", using: :btree
  add_index "profiles", ["user_group_id"], name: "index_profiles_on_user_group_id", using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree
  add_index "profiles", ["user_number"], name: "index_profiles_on_user_number", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",                     null: false
    t.string   "display_name"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",        default: 0, null: false
    t.integer  "position"
  end

  create_table "self_iccards", force: :cascade do |t|
    t.string   "card_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_has_roles", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "role_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_has_roles", ["role_id"], name: "index_user_has_roles_on_role_id", using: :btree
  add_index "user_has_roles", ["user_id"], name: "index_user_has_roles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.datetime "deleted_at"
    t.datetime "expired_at"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "confirmed_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "id_card_import_files", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "user_has_roles", "roles"
  add_foreign_key "user_has_roles", "users"
end
