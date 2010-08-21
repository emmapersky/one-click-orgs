class AddOrganisations < ActiveRecord::Migration
  def self.up
    create_table :organisations, :force => true do |t|
      t.string :subdomain
      t.timestamps
    end
  end

  def self.down
    drop_table :organisations
  end
end