require 'dm-validations'

class Decision
  include DataMapper::Resource
  include AsyncJobs
    
  property :id, Serial  
  belongs_to :proposal 
  
  def to_event
    { :timestamp => self.proposal.close_date, :object => self, :kind => :decision }    
  end 
  
  def send_email
    async_job :send_email_for, self.id
  end
  
  def self.send_email_for(decision_id)
    decision = Decision.get(decision_id)
    
    Member.all.active.each do |m|
      DecisionMailer.notify_new_decision(m, decision).deliver
      # OCOMail.send_mail(DecisionMailer, :notify_new_decision,
      #   {:to => m.email, :from => 'info@oneclickor.gs', :subject => 'new one click decision'},
      #   {:member => m, :decision => decision}
      # )
    end
  end
end