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

ActiveRecord::Schema.define(version: 20160202221606) do

  create_table "entities", force: :cascade do |t|
    t.integer  "author_id",   null: false
    t.string   "guid",        null: false
    t.string   "entity_type", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "guid",                   null: false
    t.text     "url",                    null: false
    t.string   "diaspora_id",            null: false
    t.text     "serialized_public_key",  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.text     "serialized_private_key"
  end

end
