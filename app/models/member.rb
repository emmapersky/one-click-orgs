require 'dm-validations'

class Member
  include DataMapper::Resource
  has n, :votes
  has n, :proposals, :class_name => 'Decision', :child_key => [:proposer_member_id]
  
  property :id, Serial
  property :email, String, :nullable => false
  property :name, String
  
  def cast_vote(action, proposal_id)
    existing_vote = Vote.all(:member_id => self.id, :decision_id => proposal_id)
    raise "Vote already exists for this proposal" unless existing_vote.blank?
    
    case action
    when :for
      Vote.create(:member => self, :decision_id => proposal_id, :for => true)
    when :against
      Vote.create(:member => self, :decision_id => proposal_id, :for => false)      
    end
  end


end
