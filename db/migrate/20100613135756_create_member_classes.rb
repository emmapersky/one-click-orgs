class CreateMemberClasses < ActiveRecord::Migration
  def self.up
    create_table :member_classes do |table|
      table.string    :name, :null => false
      table.string    :description
    end
    add_column :members, :member_class_id, :integer
  end

  def self.down
    drop_table :member_classes
    remove_column :members, :member_class_id
  end
end
