class AddOrganisationIdToMemberClasses < ActiveRecord::Migration
  def self.up
    add_column :member_classes, :organisation_id, :integer
  end

  def self.down
    remove_column :member_classes, :organisation_id
  end
end