class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "clauses" do |t|
      t.string   "name",          :limit => 50, :null => false
      t.datetime "started_at"
      t.datetime "ended_at"
      t.text     "text_value"
      t.integer  "integer_value"
      t.integer  "boolean_value", :limit => 1
    end

    create_table "decisions" do |t|
      t.integer "proposal_id"
    end

    create_table "members" do |t|
      t.string   "email",            :limit => 50,                :null => false
      t.string   "name",             :limit => 50
      t.datetime "created_at"
      t.integer  "active",           :limit => 1,  :default => 1
      t.string   "crypted_password", :limit => 50
      t.string   "salt",             :limit => 50
    end

    create_table "proposals" do |t|
      t.string   "title",                                              :null => false
      t.text     "description"
      t.datetime "creation_date"
      t.integer  "open",               :limit => 1,     :default => 1
      t.integer  "accepted",           :limit => 1,     :default => 0
      t.datetime "close_date"
      t.string   "parameters",         :limit => 10000
      t.string   "type",               :limit => 50
      t.integer  "proposer_member_id"
    end

    create_table "votes" do |t|
      t.integer  "member_id"
      t.integer  "proposal_id"
      t.integer  "for",         :limit => 1, :null => false
      t.datetime "created_at"
    end
  end

  def self.down
    drop_table :votes
    drop_table :proposals
    drop_table :members
    drop_table :decisions
    drop_table :clauses
  end
end
