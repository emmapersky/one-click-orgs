class Proposal < ActiveRecord::Base
  belongs_to :organisation
  
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
    self.close_date ||= Time.now.utc + organisation.constitution.voting_period
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
  
  # returns the number of members who are eligible to vote on this proposal
  def member_count
    # TODO: find out how to do the following in one query
    count = 0
    organisation.members.where(["created_at < ? AND active = 1 AND inducted_at IS NOT NULL", creation_date]).each do |m|
      count += 1 if m.has_permission(:vote)
    end
    count
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
  
  def voting_system
    organisation.constitution.voting_system(:general)
  end
    
  def passed?
    voting_system.passed?(self)
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
      decision = self.create_decision
      enact!(self.parameters)
      begin
        decision.send_email
      rescue => e
        Rails.logger.error("Error sending decision email: #{e.inspect}")
      end
    end
  end

  def parameters
    self[:parameters].blank? ? {} : ActiveSupport::JSON.decode(self[:parameters])
  end
  
  def parameters=(new_parameters)
    self[:parameters] = new_parameters.to_json
  end
  
  def self.find_closeable_early_proposals
    currently_open.all.select { |p| p.voting_system.can_be_closed_early?(p) }
  end

  def self.close_due_proposals
    where(["close_date < ? AND open = 1", Time.now.utc]).all.each { |p| p.close! }
  end
  
  def self.close_early_proposals
    find_closeable_early_proposals.each { |p| p.close! }
  end
  
  # Called every 60 seconds in the worker process (set up at end of file)
  def self.close_proposals
    close_due_proposals
    close_early_proposals
  end
  
  scope :currently_open, lambda {where(["open = 1 AND close_date > ?", Time.now.utc])}
  
  scope :failed, lambda {where(["close_date < ? AND accepted = ?", Time.now.utc, false]).order('close_date DESC')}
  
  def send_email
    self.organisation.members.active.each do |m|
      # only notify members who can vote
      ProposalMailer.notify_creation(m, self).deliver if m.has_permission(:vote)
    end
  end
  
  # only to be backwards compatible with systems running older versions of delayed job
  def self.send_email_for(proposal_id)
    Proposal.find(proposal_id).send_email_without_send_later
  end
  
  def to_event
    {:timestamp => self.creation_date, :object => self, :kind => (closed? && !accepted?) ? :failed_proposal : :proposal }
  end
  
end
