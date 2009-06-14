require 'dm-validations'

class Proposal
  LENGTH_OF_DECISION = 3.days
  include DataMapper::Resource
  
  after :create, :send_email
  has n, :votes
  has 1, :decision
  
  attr_accessor :completed, :for

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
    Vote.count(:proposal_id => self.id, :for => true)
  end
  
  def votes_against
    Vote.count(:proposal_id => self.id, :for => false)
  end
  
  def total_members
     Member.count(:created_at.lt => creation_date)
  end
  
  def abstained
    member_count - total_votes
  end
  
  def total_votes
    votes_for + votes_against
  end
  
  def accepted
    votes_for > votes_against
  end
  
  def accepted_or_rejected
    accepted ? "accepted" : "rejected"
  end
  
  def open?
    self.open
  end
  
  def closed?
    ! self.open?
  end
  
  def majority?
    num_members = Member.count(:created_at.lt => creation_date)
    return votes_for >= (num_members / 2.0).ceil
  end
    
  def close!
    raise "proposal #{self} already closed" if closed?    
    Merb.logger.info("closing proposal #{self}")
          
    Decision.create!(:proposal_id=>self.id) if majority?
    self.open = 0
    self.close_date = Time.now
    save!
  end
  
  def self.find_closed_early_proposals
    Proposal.all(:close_date.gt => Time.now).select { |p| p.majority? }
  end

  def self.close_due_proposals
   Proposal.all(:close_date.lt => Time.now, :open=>1).each { |p| p.close! }
  end
  
  def self.close_early_proposals
    find_closed_early_proposals.each { |p| p.close! }
  end
  
  def self.close_proposals
    close_due_proposals
    close_early_proposals
  end
  
  def self.all_open
    all(:open => true, :close_date.gt => Time.now)
  end
  
  def self.all_failed
    all(:close_date.lt => Time.now, :order => [:close_date.desc]).select{|v| !v.accepted}
  end
  
  
  def send_email
    Merb.run_later do
      Member.all.each do |m|
        m = Merb::Mailer.new(:to => m.email, :from => 'info@oneclickor.gs', :subject => 'new one click proposal', :text => <<-END)
        Dear #{m.name || 'member'},
        
        a new proposal has been created.
        
        "#{self.title}", by #{self.proposer.name || self.proposer.email}

        #{self.description}
        
        Please visit http://staging.oneclickor.gs/proposals to vote on it.
        
        Thanks
        
        oneclickor.gs
        END
        m.deliver!
      end
    end
  end
end