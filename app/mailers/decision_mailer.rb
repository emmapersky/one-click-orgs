class DecisionMailer < Merb::MailController
  include Merb::GlobalHelpers
  
  def notify_new_decision
    @decision = params[:decision]    
    @proposal = @decision.proposal
    @member = params[:member]    
        
    raise ArgumentError, "need decision" unless @decision and @member
    raise ArgumentError, "decision has no attached propsoal" unless @proposal
    render_mail
  end
  
end