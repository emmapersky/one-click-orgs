class Comment < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :author, :class_name => 'Member', :foreign_key => 'author_id'
end
