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

ActiveRecord::Schema.define(version: 32) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allfreets", force: :cascade do |t|
    t.integer "stage"
    t.string "name"
    t.integer "hp"
    t.integer "max_hp"
    t.integer "atk"
    t.integer "speed"
    t.string "info"
    t.string "image_url"
    t.string "object_url"
    t.integer "skill_id"
    t.integer "rarity", default: 1
    t.integer "normal", default: 0
    t.integer "rare", default: 0
    t.integer "limited", default: 0
    t.integer "story", default: 0
    t.integer "event", default: 0
  end

  create_table "alliances", force: :cascade do |t|
    t.string "join_type", default: "public", null: false
    t.string "name", null: false
    t.integer "leader_id", null: false
    t.text "description"
    t.integer "level", default: 1, null: false
    t.integer "exp", default: 0, null: false
    t.text "notice"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["leader_id"], name: "index_alliances_on_leader_id"
    t.index ["name"], name: "index_alliances_on_name", unique: true
  end

  create_table "characters", force: :cascade do |t|
    t.string "name", null: false
    t.text "bio"
    t.integer "affiliation", null: false
    t.integer "rarity", null: false
    t.integer "skill_id", null: false
  end

  create_table "chats", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "body", null: false
    t.string "category", null: false
    t.integer "alliance_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alliance_id"], name: "index_chats_on_alliance_id"
    t.index ["category", "created_at"], name: "index_chats_on_category_and_created_at"
    t.index ["category"], name: "index_chats_on_category"
    t.index ["created_at"], name: "index_chats_on_created_at"
  end

  create_table "enemy_battleunits", force: :cascade do |t|
    t.integer "battle_stage_id", null: false
    t.integer "col", null: false
    t.integer "row", null: false
    t.integer "flagship_id", null: false
    t.integer "sub_ship_1_id"
    t.integer "sub_ship_2_id"
    t.integer "sub_ship_3_id"
    t.integer "sub_ship_4_id"
    t.integer "sub_ship_5_id"
    t.integer "sub_ship_6_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "enemy_freets", force: :cascade do |t|
    t.integer "allfreet_id", null: false
    t.integer "level", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "event_type"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "category", null: false
    t.integer "rarity", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "itemtimelines", force: :cascade do |t|
    t.integer "big_type", null: false
    t.integer "small_type", null: false
    t.integer "step", null: false
    t.integer "item_type", null: false
    t.integer "item_each_id", null: false
    t.integer "count", null: false
    t.index ["item_type", "item_each_id"], name: "index_itemtimelines_on_item_type_and_item_each_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.string "effect_type", null: false
    t.integer "value", default: 0
    t.text "description"
  end

  create_table "stories", force: :cascade do |t|
    t.integer "episode", null: false
    t.integer "step", null: false
    t.string "name"
    t.text "text", null: false
    t.integer "style", default: 0
    t.integer "battle", default: 0
  end

  create_table "user_bases", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "hq_level", default: 1
    t.integer "production_level", default: 1
    t.integer "slotted_character_1_id"
    t.integer "slotted_character_2_id"
    t.integer "slotted_character_3_id"
    t.integer "slotted_character_4_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_bases_on_user_id", unique: true
  end

  create_table "user_battleunits", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "fleet_number", null: false
    t.integer "flagship_id"
    t.integer "sub_ship_1_id"
    t.integer "sub_ship_2_id"
    t.integer "sub_ship_3_id"
    t.integer "sub_ship_4_id"
    t.integer "sub_ship_5_id"
    t.integer "sub_ship_6_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "fleet_number"], name: "index_user_battleunits_on_user_id_and_fleet_number", unique: true
  end

  create_table "user_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.integer "object_id", default: 0, null: false
    t.integer "count", default: 0, null: false
    t.integer "level", default: 1, null: false
    t.integer "exp", default: 0, null: false
    t.integer "weapon_id"
    t.integer "character_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "mail", null: false
    t.string "password_digest"
    t.string "uid"
    t.string "provider"
    t.integer "level", default: 1, null: false
    t.integer "exp", default: 0, null: false
    t.integer "alliance_id"
    t.integer "alliance_role", default: 0, null: false
    t.integer "user_lank_id", default: 1, null: false
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  create_table "usersteps", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "limited_gacha_step", default: 1
    t.index ["user_id"], name: "index_usersteps_on_user_id"
  end

  create_table "weapons", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "rarity", null: false
    t.integer "price", default: 0, null: false
    t.integer "skill_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
