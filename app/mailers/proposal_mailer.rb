class ProposalMailer < Merb::MailController

  def notify_creation
    @member = params[:member]
    @proposal = params[:proposal]
    render_mail
  end
  
end
