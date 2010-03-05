class DecisionMailer < ActionMailer::Base
  helper :application
  
  default :from => "info@oneclickor.gs"
  
  def notify_new_decision(member, decision)
    default_url_options[:host] = Organisation.domain
    
    @decision = decision
    @proposal = @decision.proposal
    @member = member
    
    raise ArgumentError, "need decision" unless @decision and @member
    raise ArgumentError, "decision has no attached propsoal" unless @proposal
    mail(:to => @member.email, :subject => "new one click decision")
  end
end
