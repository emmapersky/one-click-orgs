require 'dm-validations'

class Decision
  LENGTH_OF_DECISION = 3.days
  include DataMapper::Resource
  has n, :votes
  
  #class << self
    attr_accessor :completed, :for
  #end
  
  belongs_to :proposer, :class_name => 'Member', :child_key => [:proposer_member_id]
  
  property :id, Serial
  property :title, String, :nullable => false
  property :description, Text
  property :creation_date, DateTime, :default => Proc.new {|r,p| Time.now.to_datetime}
  property :open, Boolean, :default => true
  property :accepted, Boolean, :default => false
  
  validates_present :proposer_member_id
  
  def end_date
    creation_date.to_time + 3.days
  end
end