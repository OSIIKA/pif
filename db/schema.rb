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

ActiveRecord::Schema.define(version: 16) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allfreets", force: :cascade do |t|
    t.integer "stage"
    t.string "name"
    t.integer "hp"
    t.integer "max_hp"
    t.integer "atk"
    t.string "info"
  end

  create_table "battleunits", force: :cascade do |t|
    t.string "name"
    t.integer "hp"
    t.integer "atk"
    t.string "info"
  end

  create_table "myfreets", force: :cascade do |t|
    t.string "name"
    t.integer "hp"
    t.integer "max_hp"
    t.integer "atk"
    t.string "info"
  end

  create_table "storys", force: :cascade do |t|
    t.integer "episode", null: false
    t.integer "step", null: false
    t.string "name"
    t.text "text", null: false
    t.integer "style", default: 0
    t.integer "battle", default: 0
  end

  create_table "user_lanks", force: :cascade do |t|
    t.string "name", null: false
    t.text "text"
    t.integer "event1", null: false
    t.integer "event2", null: false
    t.integer "required_exp", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_myfreets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "myfreet_id"
    t.integer "level"
    t.integer "exp"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "mail"
    t.string "password_digest"
    t.integer "level"
    t.integer "exp"
    t.string "provider"
    t.string "uid"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

end
