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

ActiveRecord::Schema[8.1].define(version: 2025_12_29_155205) do
  create_table "command_runs", force: :cascade do |t|
    t.string "command", null: false
    t.string "org_ref"
    t.json "options", default: {}
    t.string "status", default: "pending", null: false
    t.text "error"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_command_runs_on_created_at"
    t.index ["org_ref"], name: "index_command_runs_on_org_ref"
    t.index ["status"], name: "index_command_runs_on_status"
  end
end
