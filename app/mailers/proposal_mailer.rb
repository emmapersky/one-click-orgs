class ProposalMailer < Merb::MailController
  include Merb::GlobalHelpers
  
  def notify_creation
    @member = params[:member]
    @proposal = params[:proposal]
    
    raise ArgumentError, "need member and proposal" unless @member and @proposal
    render_mail
  end
  
  def self.get_subject(proposal)
    "New proposal: #{proposal.title}"
  end
  
end
