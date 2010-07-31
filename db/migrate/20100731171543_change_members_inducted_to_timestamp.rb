class ChangeMembersInductedToTimestamp < ActiveRecord::Migration
  class Member < ActiveRecord::Base
  end
  
  def self.up
    add_column :members, :inducted_at, :timestamp
    Member.all.each do |m|
      m.update_attribute(:inducted_at, m.created_at)
    end
    remove_column :members, :inducted
  end

  def self.down
    add_column :members, :inducted, :boolean, :default => false, :null => false
    Member.all.each do |m|
      m.update_attribute(:inducted, (m.inducted_at ? true : false))
    end
    remove_column :members, :inducted_at
  end
end
