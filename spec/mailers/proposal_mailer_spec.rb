require File.join(File.dirname(__FILE__), "..", "spec_helper")

module MailControllerTestHelper
  # Helper to deliver
  def deliver(action, mail_params = {}, send_params = {})
    ProposalMailer.dispatch_and_deliver(action, { :from => "no-reply@webapp.com", :to => "recepient@person.com" }.merge(mail_params), send_params)
    @delivery = last_delivered_mail
  end
end

describe ProposalMailer, "#notify_creation email template" do
  include MailControllerTestHelper
  
  before :each do
    clear_mail_deliveries
    
    @member, @proposal = mock(Member), mock(Proposal)
    @member.stub!(:name).and_return("Peter Pan")
    @proposal.stub!(:title).and_return("grow up")
    @proposal.stub!(:description).and_return("later")
    @proposal.stub!(:proposer).and_return(@member) 

  end
    
  it "includes welcome phrase and proposal information in email text" do    
    ProposalMailer.dispatch_and_deliver(:notify_creation, {}, { :member => @member, :proposal => @proposal })
    last_delivered_mail.text.should =~ /Dear #{@member.name}/
    last_delivered_mail.text.should =~ /#{@proposal.title}/
    last_delivered_mail.text.should =~ /#{@proposal.description}/            
  end
end