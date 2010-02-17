class Member < ActiveRecord::Base
  has_many :votes
  has_many :proposals, :foreign_key => 'proposer_member_id'
  
  scope :active, where(:active => true)
  
  def cast_vote(action, proposal_id)
    raise ArgumentError, "need action and proposal_id" unless action and proposal_id
    
    existing_vote = Vote.where(:member_id => self.id, :proposal_id => proposal_id).first
    raise VoteError, "Vote already exists for this proposal" if existing_vote
    
    # FIXME why not just pass the proposal in?
    proposal = Proposal.find(proposal_id)
    raise VoteError, "proposal with id #{proposal_id} not found" unless proposal
    raise VoteError, "Can not vote on proposals created before member created" if proposal.creation_date < self.created_at
    
    case action
    when :for
      Vote.create(:member => self, :proposal_id => proposal_id, :for => true)
    when :against
      Vote.create(:member => self, :proposal_id => proposal_id, :for => false)      
    end
  end
  
  def new_password!(n=6)
    raise ArgumentError, "password must have at least 6 characters" if n < 6
    chars = ["a".."z", "A".."Z", "0".."9"].map(&:to_a).flatten
    self.password = self.password_confirmation = (1..n).map { chars[rand(chars.size-1)] }.join
  end
  
  def self.create_member(params, send_welcome=false)
    member = Member.new(params)
    member.new_password!
    member.send_welcome if send_welcome
    member.save
  end
  
  def send_welcome
    # TODO Convert to new background job system
    async_job :send_new_member_email, self.id, self.password
  end
  
  def self.send_new_member_email(member_id, password)
    member = Member.find(member_id)
    MembersMailer.welcome_new_member(member, password).deliver
  end  
  
  def eject!
    self.active = false
    save
  end
  
  def to_event
    {:timestamp => self.created_at, :object => self, :kind => :new_member}
  end
end

