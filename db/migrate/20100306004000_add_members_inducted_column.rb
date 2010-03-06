class AddMembersInductedColumn < ActiveRecord::Migration
  def self.up
    add_column :members, :inducted, :boolean, :null => false, :default => 0
  end
  
  def self.down
    remove_column :members, :inducted
  end
end
