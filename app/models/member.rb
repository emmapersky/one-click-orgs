require 'dm-validations'

class Member
  include DataMapper::Resource
  
  after :create, :send_welcome  
  has n, :votes
  has n, :proposals, :class_name => 'Proposal', :child_key => [:proposer_member_id]
  
  property :id, Serial
  property :email, String, :nullable => false
  property :name, String
  property :created_at, DateTime, :default => Proc.new {|r,p| Time.now.to_datetime}
  
  def cast_vote(action, proposal_id)
    raise ArgumentError, "need action and proposal_id" unless action and proposal_id
    
    existing_vote = Vote.all(:member_id => self.id, :proposal_id => proposal_id)
    raise VoteError, "Vote already exists for this proposal" unless existing_vote.blank?
    
    proposal = Proposal.get(proposal_id)
    raise VoteError, "proposal with id #{proposal_id} not found" unless proposal
    raise VoteError, "Can not vote on proposals created before member created" if proposal.creation_date < self.created_at
    
    case action
    when :for
      Vote.create(:member => self, :proposal_id => proposal_id, :for => true)
    when :against
      Vote.create(:member => self, :proposal_id => proposal_id, :for => false)      
    end
  end
  
  def new_password!
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    new_password = ""
    1.upto(6) { new_password << chars[rand(chars.size-1)] }
    self.password = new_password
    self.password_confirmation = new_password
    new_password
  end
  
  def self.create_member(params)
    member = Member.new(params)
    member.new_password!
    member.save
  end
  
  def send_welcome
    #do some email sending magic
  end
end

#error class
class VoteError < RuntimeError; end