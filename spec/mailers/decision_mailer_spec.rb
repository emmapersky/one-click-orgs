require File.join(File.dirname(__FILE__), "..", "spec_helper")


describe DecisionMailer, "#notify_new_decision email template" do
  include MailControllerTestHelper

  before :each do
    clear_mail_deliveries
    stub_constitution!    
    @member = Member.make
    @proposal = Proposal.make(:proposer_member_id=>@member.id)
    @decision = Decision.make(:proposal=>@proposal)
  end
    
  it "includes welcome phrase and proposal information in email text" do    
    DecisionMailer.dispatch_and_deliver(:notify_new_decision, {}, { :member => @member, :decision => @decision })
    last_delivered_mail.text.should =~ /Dear #{@member.name}/
    last_delivered_mail.text.should =~ /a new decision has been made/
    last_delivered_mail.text.should =~ /#{@proposal.title}/
    last_delivered_mail.text.should =~ /#{@proposal.description}/            
  end
  
  it "includes correct decision link in email text" do
#    ProposalMailer.dispatch_and_deliver(:notify_new_decision, {}, { :member => @member, :decision => @decision })
#    last_delivered_mail.text.should =~ %r{http://test.com/decisions/\d+}
  end
end