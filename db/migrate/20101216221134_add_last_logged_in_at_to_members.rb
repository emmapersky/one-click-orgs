class AddLastLoggedInAtToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :last_logged_in_at, :timestamp
  end

  def self.down
    remove_column :members, :last_logged_in_at
  end
end