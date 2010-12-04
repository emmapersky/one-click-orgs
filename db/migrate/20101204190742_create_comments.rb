class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :author_id
      t.integer :proposal_id
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
