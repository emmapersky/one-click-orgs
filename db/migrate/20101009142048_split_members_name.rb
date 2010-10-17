class SplitMembersName < ActiveRecord::Migration
  class Member < ActiveRecord::Base; end
  
  def self.up
    add_column :members, :first_name, :string
    add_column :members, :last_name, :string
    
    Member.all.each do |member|
      names = member.name.split(/\s/)
      if names.length == 1
        member.first_name = names[0]
      else
        member.last_name = names.pop
        member.first_name = names.join(' ')
      end
      member.save!
    end
    
    remove_column :members, :name
  end

  def self.down
    add_column :members, :name, :string, :limit => 50, :null => false
    
    Member.all.each do |member|
      member.name = [member.first_name, member.last_name].join(' ')
      member.save!
    end
    
    remove_column :members, :last_name
    remove_column :members, :first_name
  end
end
