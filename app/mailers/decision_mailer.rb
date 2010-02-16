class DecisionMailer < ActionMailer::Base
  default :from => "info@oneclickor.gs"
  
  def notify_new_decision(member, decision)
    @decision = decision
    @proposal = @decision.proposal
    @member = member
    
    raise ArgumentError, "need decision" unless @decision and @member
    raise ArgumentError, "decision has no attached propsoal" unless @proposal
    mail(:to => @member.email, :subject => "new one click decision")
  end
end
