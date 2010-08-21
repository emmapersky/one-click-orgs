class AddOrganisationRelationships < ActiveRecord::Migration
  def self.up
    add_column :clauses, :organisation_id, :integer
    add_column :members, :organisation_id, :integer
    add_column :proposals, :organisation_id, :integer
  end

  def self.down
    remove_column :proposals, :organisation_id
    remove_column :members, :organisation_id
    remove_column :clauses, :organisation_id
  end
end