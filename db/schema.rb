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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130726034353) do

  create_table "images", :force => true do |t|
    t.integer  "order_id"
    t.integer  "index"
    t.string   "path"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "orders", :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "workflow_state"
    t.string   "receiver_name"
    t.string   "receiver_address"
    t.string   "receiver_code"
    t.string   "receiver_contact"
    t.integer  "user_id"
    t.string   "status"
    t.string   "content"
  end

  create_table "users", :force => true do |t|
    t.string   "openid"
    t.string   "workflow_state"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end
