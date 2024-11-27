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

ActiveRecord::Schema.define(version: 2024_11_26_154328) do

  create_table "cards", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "due_date"
    t.string "trello_card_id", null: false
    t.string "trello_list_id", null: false
    t.index ["trello_list_id"], name: "index_cards_on_trello_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name", null: false
    t.string "trello_list_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trello_list_id"], name: "index_lists_on_trello_list_id", unique: true
  end

end
