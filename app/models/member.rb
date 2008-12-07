require 'dm-validations'

class Member
  include DataMapper::Resource
  has n, :votes
  has n, :proposals, :class_name => 'Decision', :child_key => [:proposer_member_id]
  
  property :id, Serial
  property :email, String, :nullable => false
  property :name, String



end
