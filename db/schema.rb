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

ActiveRecord::Schema.define(version: 2019_02_24_184553) do

  create_table "cash_outs", force: :cascade do |t|
    t.integer "p_game_id"
    t.string "name"
    t.integer "buyin"
    t.integer "buyout"
  end

  create_table "games", force: :cascade do |t|
    t.string "winner"
    t.string "losers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
    t.string "elochange"
    t.string "tableelo"
  end

  create_table "p_games", force: :cascade do |t|
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "elo"
    t.integer "wins"
    t.integer "losses"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "elov2", default: 1200.0
    t.integer "elov3", default: 1200
  end

  create_table "poker_games", force: :cascade do |t|
    t.string "cashout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "poker_players", force: :cascade do |t|
    t.string "name"
    t.float "elo"
    t.integer "buyins"
    t.integer "cashout"
    t.integer "games"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
