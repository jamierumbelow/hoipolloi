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

ActiveRecord::Schema.define(version: 20130611070420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversations", force: true do |t|
    t.integer  "user_id"
    t.boolean  "read"
    t.integer  "start_tweet_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversations", ["start_tweet_id"], name: "index_conversations_on_start_tweet_id", unique: true, using: :btree
  add_index "conversations", ["user_id"], name: "index_conversations_on_user_id", using: :btree

  create_table "tweets", force: true do |t|
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.integer  "tweet_id",        limit: 8
    t.string   "from_name"
    t.text     "text"
    t.datetime "tweeted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tweets", ["conversation_id"], name: "index_tweets_on_conversation_id", using: :btree
  add_index "tweets", ["tweet_id"], name: "index_tweets_on_tweet_id", unique: true, using: :btree
  add_index "tweets", ["user_id"], name: "index_tweets_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.integer  "uid",        limit: 8
    t.string   "name"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

end
