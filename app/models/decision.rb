class Decision < ActiveRecord::Base
  belongs_to :proposal
  
  def organisation
    proposal.organisation if proposal
  end
  
  def to_event
    { :timestamp => self.proposal.close_date, :object => self, :kind => :decision }    
  end 
  
  def send_email
    self.organisation.members.active.each do |m|
      DecisionMailer.notify_new_decision(m, self).deliver
    end
  end
  
  # only to be backwards compatible with systems running older versions of delayed job
  def self.send_email_for(decision_id)
    Decision.find(decision_id).send_email_without_send_later
  end
end
