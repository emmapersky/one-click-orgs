require 'dm-validations'

class Decision
  include DataMapper::Resource
  has n, :votes

  belongs_to :proposer, :class_name => 'Member', :child_key => [:proposer_member_id]
  
  property :id, Serial
  property :title, String, :nullable => false
  property :description, Text
  property :creation_date, DateTime, :default => Proc.new {|r,p| Time.now}
  property :open, Boolean, :default => true
  property :accepted, Boolean, :default => false
  
  validates_present :proposer_member_id
end