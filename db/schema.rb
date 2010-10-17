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

ActiveRecord::Schema.define(:version => 20101009142048) do

  create_table "clauses", :force => true do |t|
    t.string   "name",            :limit => 50, :null => false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.text     "text_value"
    t.integer  "integer_value"
    t.integer  "boolean_value",   :limit => 1
    t.integer  "organisation_id"
  end

  create_table "decisions", :force => true do |t|
    t.integer "proposal_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_classes", :force => true do |t|
    t.string  "name",            :null => false
    t.string  "description"
    t.integer "organisation_id"
  end

  create_table "members", :force => true do |t|
    t.string   "email",            :limit => 50,                :null => false
    t.datetime "created_at"
    t.integer  "active",           :limit => 1,  :default => 1
    t.string   "crypted_password", :limit => 50
    t.string   "salt",             :limit => 50
    t.integer  "organisation_id"
    t.integer  "member_class_id"
    t.datetime "inducted_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  create_table "organisations", :force => true do |t|
    t.string   "subdomain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proposals", :force => true do |t|
    t.string   "title",                                              :null => false
    t.text     "description"
    t.datetime "creation_date"
    t.integer  "open",               :limit => 1,     :default => 1
    t.integer  "accepted",           :limit => 1,     :default => 0
    t.datetime "close_date"
    t.string   "parameters",         :limit => 10000
    t.string   "type",               :limit => 50
    t.integer  "proposer_member_id"
    t.integer  "organisation_id"
  end

  create_table "settings", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes", :force => true do |t|
    t.integer  "member_id"
    t.integer  "proposal_id"
    t.integer  "for",         :limit => 1, :null => false
    t.datetime "created_at"
  end

end
