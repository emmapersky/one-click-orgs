class AddPasswordResetCodeToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :password_reset_code, :string
  end

  def self.down
    remove_column :members, :password_reset_code
  end
end