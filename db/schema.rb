# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2026_06_02_150419) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_reports", force: :cascade do |t|
    t.text "original_url"
    t.text "normalized_url"
    t.string "domain"
    t.text "ticket_url"
    t.string "ticket_id"
    t.string "agent_email"
    t.string "agent_name"
    t.text "agent_note"
    t.integer "risk_score", default: 0, null: false
    t.string "risk_level", default: "safe", null: false
    t.jsonb "reasons", default: [], null: false
    t.string "status", default: "pending", null: false
    t.string "reviewer_email"
    t.text "reviewer_note"
    t.datetime "reviewed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["agent_email"], name: "index_agent_reports_on_agent_email"
    t.index ["created_at"], name: "index_agent_reports_on_created_at"
    t.index ["domain"], name: "index_agent_reports_on_domain"
    t.index ["status"], name: "index_agent_reports_on_status"
  end

  create_table "allowlisted_domains", force: :cascade do |t|
    t.string "domain", null: false
    t.boolean "allow_subdomains", default: false, null: false
    t.text "notes"
    t.string "created_by"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["active"], name: "index_allowlisted_domains_on_active"
    t.index ["domain"], name: "index_allowlisted_domains_on_domain", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "user_email"
    t.string "action", null: false
    t.string "record_type"
    t.integer "record_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["record_type", "record_id"], name: "index_audit_logs_on_record_type_and_record_id"
    t.index ["user_email"], name: "index_audit_logs_on_user_email"
  end

  create_table "blocked_domains", force: :cascade do |t|
    t.string "domain", null: false
    t.string "severity", default: "high", null: false
    t.text "reason"
    t.string "created_by"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["active"], name: "index_blocked_domains_on_active"
    t.index ["domain"], name: "index_blocked_domains_on_domain", unique: true
    t.index ["severity"], name: "index_blocked_domains_on_severity"
  end

  create_table "security_settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.string "updated_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_security_settings_on_key", unique: true
  end

  create_table "url_scans", force: :cascade do |t|
    t.text "original_url"
    t.text "normalized_url"
    t.string "domain"
    t.integer "risk_score", default: 0, null: false
    t.string "risk_level", default: "safe", null: false
    t.string "action_taken", default: "allowed", null: false
    t.jsonb "reasons", default: [], null: false
    t.string "agent_email"
    t.string "agent_name"
    t.text "ticket_url"
    t.string "ticket_id"
    t.text "user_agent"
    t.string "device_name"
    t.string "source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action_taken"], name: "index_url_scans_on_action_taken"
    t.index ["agent_email"], name: "index_url_scans_on_agent_email"
    t.index ["created_at"], name: "index_url_scans_on_created_at"
    t.index ["domain"], name: "index_url_scans_on_domain"
    t.index ["risk_level"], name: "index_url_scans_on_risk_level"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "admin", null: false
    t.string "ad_username"
    t.string "password_digest", null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

end
