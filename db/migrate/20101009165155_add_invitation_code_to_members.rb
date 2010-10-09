class AddInvitationCodeToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :invitation_code, :string
  end

  def self.down
    remove_column :members, :invitation_code
  end
end