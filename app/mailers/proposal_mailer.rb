class ProposalMailer < ActionMailer::Base
  default :from => "info@oneclickor.gs"
  
  def notify_creation(member, proposal)
    @member = member
    @proposal = proposal
    
    raise ArgumentError, "need member and proposal" unless @member and @proposal
    
    mail(:to => @member.email, :subject => "New proposal: #{@proposal.title}")
  end
end
