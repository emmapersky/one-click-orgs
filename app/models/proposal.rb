class Proposal < ActiveRecord::Base
  #TODO: should probably not be in a hook method?
  after_create :send_email
  
  has_many :votes
  has_one :decision
  
  belongs_to :proposer, :class_name => 'Member', :foreign_key => 'proposer_member_id'
  
  before_create :set_creation_date
  private
  def set_creation_date
    self.creation_date ||= Time.now.utc
  end
  public
  
  before_create :set_close_date
  private
  def set_close_date
    self.close_date ||= Time.now.utc + Constitution.voting_period
  end
  public
  
  
  validates_presence_of :proposer_member_id
  
  def end_date
    self.close_date
  end
  
  # Returns a Vote by the member specified, or Nil
  def vote_by(member)
    member.votes.where(:proposal_id => self.id).first
  end
  
  def votes_for
    Vote.where(:proposal_id => self.id, :for => true).count
  end
  
  def votes_against
    Vote.where(:proposal_id => self.id, :for => false).count
  end
  
  def total_members
    Member.where(["created_at < ?", creation_date]).count
  end
  
  def abstained
    member_count - total_votes
  end
  
  def total_votes
    votes_for + votes_against
  end
  
  def reject!
    # TODO do some kind of email notification
  end
  
  def accepted_or_rejected
    accepted? ? "accepted" : "rejected"
  end
  
  def enact!(params={})
  end
  
  def closed?
    ! self.open?
  end
  
  def majority?
    #FIXME, voting system?
    num_members = Member.where(["created_at < ?", creation_date]).count
    return votes_for >= (num_members / 2.0).ceil
  end

  def passed?
    voting_system.passed?(self)
  end
  
  def voting_system
    Constitution.voting_system(:general)
  end
    
  def close!
    raise "proposal #{self} already closed" if closed?   
        
    passed = passed?
    Rails.logger.info("closing proposal #{self}")
        
    self.open = 0
    self.close_date = Time.now
    self.accepted = passed
    save!
    
    if passed
      decision = Decision.create!(:proposal_id=>self.id)
      decision.send_email
      
      params = self.parameters ? ActiveSupport::JSON.decode(self.parameters) : {}      
      enact!(params) 
    end
  end


  def self.serialize_parameters(params)
    params.to_json
  end
  
  def self.find_closed_early_proposals
    Proposal.where(["close_date > ?", Time.now.utc]).all.select { |p| p.majority? }
  end

  def self.close_due_proposals
   Proposal.where(["close_date < ? AND open = ?", Time.now.utc, true]).all.each { |p| p.close! }
  end
  
  def self.close_early_proposals
    find_closed_early_proposals.each { |p| p.close! }
  end
  
  # Called every 60 seconds in the worker process (set up at end of file)
  def self.close_proposals
    close_due_proposals
    close_early_proposals
  end
  
  scope :currently_open, lambda {where(["open = ? AND close_date > ?", true, Time.now.utc])}
  
  scope :failed, lambda {where(["close_date < ? AND accepted = ?", Time.now.utc, false]).order('close_date DESC')}
  
  def send_email
    # TODO Convert to new background job system
    #async_job :send_email_for, self.id
    Proposal.send_email_for(self.id)
  end
  
  def self.send_email_for(proposal_id)
    proposal = Proposal.find(proposal_id)
    
    Member.active.each do |m|
      ProposalMailer.notify_creation(m, proposal).deliver
    end
  end
  
  def to_event
    {:timestamp => self.creation_date, :object => self, :kind => (closed? && !accepted?) ? :failed_proposal : :proposal }
  end
  
end

# Run the close proposal every 60 seconds
# TODO Convert to new background job system
# AsyncJobs.periodical Proposal, 60, :close_proposals

