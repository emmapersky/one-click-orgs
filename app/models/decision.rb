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
  property :title, String, :nullable => false, :length => 255
  property :description, Text
  property :creation_date, DateTime, :default => Proc.new {|r,p| Time.now.to_datetime}
  property :open, Boolean, :default => true
  property :accepted, Boolean, :default => false
  property :close_date, DateTime, :default => Proc.new {|r,p| (Time.now + LENGTH_OF_DECISION).to_datetime}
  validates_present :proposer_member_id
  
  def end_date
    self.close_date
  end
  
  def votes_for
    self.votes.select{|v| v.for}.size        
  end
  
  def votes_against
    self.votes.select{|v| ! v.for}.size    
  end
  
  def accepted
    votes_for > votes_against
  end
  
  def accepted_or_rejected
    accepted ? "accepted" : "rejected"
  end
  
  def open?
    close_date < Time.now.to_datetime ? false : true
  end
  
  def closed?
    ! self.open?
  end
end