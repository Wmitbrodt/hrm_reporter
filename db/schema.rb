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

ActiveRecord::Schema[7.2].define(version: 2026_01_19_024754) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hrm_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "imported_created_at"
    t.integer "duration_secs"
    t.bigint "external_id"
    t.integer "min_bpm"
    t.integer "max_bpm"
    t.decimal "avg_bpm"
    t.integer "total_duration_secs"
    t.bigint "weighted_bpm_sum"
    t.integer "zone1_secs"
    t.integer "zone2_secs"
    t.integer "zone3_secs"
    t.integer "zone4_secs"
    t.jsonb "chart_points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_hrm_sessions_on_external_id", unique: true
    t.index ["user_id"], name: "index_hrm_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "gender"
    t.integer "age"
    t.integer "zone1_min"
    t.integer "zone1_max"
    t.integer "zone2_min"
    t.integer "zone2_max"
    t.integer "zone3_min"
    t.integer "zone3_max"
    t.integer "zone4_min"
    t.integer "zone4_max"
    t.datetime "imported_created_at"
    t.bigint "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_users_on_external_id", unique: true
  end

  add_foreign_key "hrm_sessions", "users"
end
