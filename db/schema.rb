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

ActiveRecord::Schema[8.1].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "appointment_status", ["scheduled", "rescheduled", "completed", "no_show", "cancelled"]
  create_enum "order_status", ["pending", "approved", "fulfilled", "cancelled"]
  create_enum "user_role", ["admin", "provider", "patient"]
  create_enum "user_status", ["active", "inactive", "locked"]

  create_table "appointments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.timestamptz "end_at"
    t.text "notes"
    t.uuid "patient_id", null: false
    t.uuid "provider_id", null: false
    t.timestamptz "start_at", null: false
    t.enum "status", default: "scheduled", null: false, enum_type: "appointment_status"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["patient_id", "start_at"], name: "idx_appointments_patient_time"
    t.index ["provider_id", "start_at"], name: "idx_appointments_provider_time"
    t.check_constraint "end_at IS NULL OR start_at < end_at", name: "appointments_check"
  end

  create_table "hearing_aids", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "manufacturer", null: false
    t.text "model", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false

    t.check_constraint "price >= 0::numeric", name: "hearing_aids_price_check"
    t.unique_constraint ["manufacturer", "model"], name: "hearing_aids_manufacturer_model_key"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.uuid "hearing_aid_id", null: false
    t.text "notes"
    t.uuid "patient_id", null: false
    t.uuid "provider_id", null: false
    t.enum "status", default: "pending", null: false, enum_type: "order_status"
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["patient_id"], name: "idx_orders_patient_id"
    t.index ["provider_id"], name: "idx_orders_provider_id"
    t.index ["status"], name: "idx_orders_status"
    t.check_constraint "total_price >= 0::numeric", name: "orders_total_price_check"
  end

  create_table "patients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.date "dob"
    t.text "insurance_id"
    t.text "name", null: false
    t.text "phone"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.uuid "user_id"
    t.index ["user_id"], name: "idx_patients_user_id"
    t.unique_constraint ["user_id"], name: "patients_user_id_key"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.text "clinic_name", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "phone"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.uuid "user_id"
    t.index ["user_id"], name: "idx_providers_user_id"
    t.unique_constraint ["user_id"], name: "providers_user_id_key"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.citext "email", null: false
    t.text "password_digest", null: false
    t.enum "role", default: "patient", null: false, enum_type: "user_role"
    t.enum "status", default: "active", null: false, enum_type: "user_status"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["email"], name: "idx_users_email"
    t.unique_constraint ["email"], name: "users_email_key"
  end

  add_foreign_key "appointments", "patients", name: "appointments_patient_id_fkey", on_delete: :restrict
  add_foreign_key "appointments", "providers", name: "appointments_provider_id_fkey", on_delete: :restrict
  add_foreign_key "orders", "hearing_aids", name: "orders_hearing_aid_id_fkey", on_delete: :restrict
  add_foreign_key "orders", "patients", name: "orders_patient_id_fkey", on_delete: :restrict
  add_foreign_key "orders", "providers", name: "orders_provider_id_fkey", on_delete: :restrict
  add_foreign_key "patients", "users", name: "patients_user_id_fkey", on_delete: :cascade
  add_foreign_key "providers", "users", name: "providers_user_id_fkey", on_delete: :cascade
end
