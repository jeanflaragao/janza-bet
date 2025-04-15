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

ActiveRecord::Schema[8.0].define(version: 2025_04_15_211234) do
  create_table "bets", charset: "utf8mb3", force: :cascade do |t|
    t.date "event_date"
    t.string "game"
    t.text "bet"
    t.decimal "stake", precision: 10
    t.decimal "odd", precision: 10
    t.string "status"
    t.bigint "book_id", null: false
    t.bigint "tipster_id"
    t.decimal "result", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_bets_on_book_id"
    t.index ["tipster_id"], name: "index_bets_on_tipster_id"
    t.index ["user_id"], name: "index_bets_on_user_id"
  end

  create_table "books", charset: "utf8mb3", force: :cascade do |t|
    t.string "owner"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "inactive", default: false, null: false
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "daily_balances", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.decimal "balance", precision: 10
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_daily_balances_on_book_id"
  end

  create_table "sessions", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tipsters", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.string "transaction_type"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 10
    t.decimal "amount", precision: 10
    t.index ["book_id"], name: "index_transactions_on_book_id"
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "bets", "books"
  add_foreign_key "bets", "tipsters"
  add_foreign_key "bets", "users"
  add_foreign_key "books", "users"
  add_foreign_key "daily_balances", "books"
  add_foreign_key "sessions", "users"
  add_foreign_key "transactions", "books"
end
