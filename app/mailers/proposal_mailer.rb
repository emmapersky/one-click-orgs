class ProposalMailer < ActionMailer::Base
  helper :application
  
  default :from => "info@oneclickorgs.com"
  
  def notify_creation(member, proposal)
    default_url_options[:host] = Organisation.domain(:only_host => true)
    
    @member = member
    @proposal = proposal
    
    raise ArgumentError, "need member and proposal" unless @member and @proposal
    
    mail(:to => @member.email, :subject => "New proposal: #{@proposal.title}")
  end
end
