require 'dm-validations'

class Decision
  LENGTH_OF_DECISION = 3.days
  include DataMapper::Resource
  
  after :create, :send_email
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
  
  def self.find_closed_early_decisions
    decisions = []
    ds = Decision.all(:close_date.gt => Time.now)
    ds.each do |d|
      m = Member.count(:created_at.lt => d.creation_date)
      v = Vote.count(:decision_id => d.id, :for => true)
      decisions << d if v > (m / 2.0).ceil
    end
    decisions
  end
  
  def initialize(*args)
    super
  end
  
  def send_email
    Thread.start do
      emails = Member.all.map{|m| m.email}
      emails.each do |email|
        m = Merb::Mailer.new(:to => email, :from => 'test@barcamplondon.org', :subject => 'new one click proposal', :text => "#{self.title}")
        m.deliver!
      end
    end
  end
end