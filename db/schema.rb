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

ActiveRecord::Schema.define(version: 20140525215522) do

  create_table "FriendshipRequests", force: true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contributions", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
    t.string   "platform"
  end

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id"
  add_index "friendships", ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id"

  create_table "messages", force: true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_seen"
    t.string   "content"
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "ride_id"
    t.string   "message_type"
    t.datetime "date_time"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.integer  "ride_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.integer  "phase"
    t.float    "fundings_target"
    t.integer  "owner_id"
    t.string   "description"
    t.string   "title"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ride_id"
  end

  create_table "push_configurations", force: true do |t|
    t.string   "type",                        null: false
    t.string   "app",                         null: false
    t.text     "properties"
    t.boolean  "enabled",     default: false, null: false
    t.integer  "connections", default: 1,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "push_feedback", force: true do |t|
    t.string   "app",                          null: false
    t.string   "device",                       null: false
    t.string   "type",                         null: false
    t.string   "follow_up",                    null: false
    t.datetime "failed_at",                    null: false
    t.boolean  "processed",    default: false, null: false
    t.datetime "processed_at"
    t.text     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "push_feedback", ["processed"], name: "index_push_feedback_on_processed"

  create_table "push_messages", force: true do |t|
    t.string   "app",                               null: false
    t.string   "device",                            null: false
    t.string   "type",                              null: false
    t.text     "properties"
    t.boolean  "delivered",         default: false, null: false
    t.datetime "delivered_at"
    t.boolean  "failed",            default: false, null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.string   "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "push_messages", ["delivered", "failed", "deliver_after"], name: "index_push_messages_on_delivered_and_failed_and_deliver_after"

  create_table "ratings", force: true do |t|
    t.integer  "to_user_id"
    t.integer  "from_user_id"
    t.integer  "rating_type"
    t.integer  "ride_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", force: true do |t|
    t.integer  "user_id"
    t.integer  "ride_id"
    t.boolean  "is_driving"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "driver_ride_id"
  end

  add_index "relationships", ["ride_id"], name: "index_relationships_on_ride_id"
  add_index "relationships", ["user_id", "ride_id"], name: "index_relationships_on_user_id_and_ride_id", unique: true
  add_index "relationships", ["user_id"], name: "index_relationships_on_user_id"

  create_table "requests", force: true do |t|
    t.integer  "ride_id"
    t.integer  "passenger_id"
    t.string   "requested_from"
    t.string   "request_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ride_searches", force: true do |t|
    t.integer  "user_id"
    t.string   "departure_place"
    t.string   "destination"
    t.datetime "departure_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ride_type"
  end

  create_table "rides", force: true do |t|
    t.string   "departure_place"
    t.string   "destination"
    t.datetime "departure_time"
    t.integer  "free_seats"
    t.integer  "user_id"
    t.string   "meeting_point"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "realtime_km"
    t.float    "price"
    t.datetime "realtime_departure_time"
    t.float    "duration"
    t.datetime "realtime_arrival_time"
    t.integer  "contribution_mode"
    t.boolean  "is_paid"
    t.boolean  "is_finished"
    t.float    "distance"
    t.integer  "ride_type"
  end

  add_index "rides", ["user_id"], name: "index_rides_on_user_id"

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "department"
    t.string   "car"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin"
    t.string   "api_key"
    t.boolean  "is_student"
    t.integer  "rank"
    t.float    "unbound_contributions"
    t.integer  "exp"
    t.boolean  "gamification"
    t.float    "rating_avg"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
