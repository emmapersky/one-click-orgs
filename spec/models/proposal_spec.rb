require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Proposal do
  include MailControllerTestHelper
  
  before(:each) do
    stub_constitution!  
    stub_organisation!
    
    @member = Member.make
    clear_mail_deliveries
    
    Constitution.stub!(:voting_system).and_return(VotingSystems.get(:RelativeMajority))
  end

  it "should close early proposals" do
    member_0, member_1, member_2 = Member.make_n(3)
    member_3, member_4 = Member.make_n(2, :created_at => Time.now + 1.day) 
    
    proposal = Proposal.create!(:proposer_member_id => member_1.id, :title => 'test')            
    [member_0, member_1, member_2].each { |m| m.cast_vote(:for, proposal.id)}
    
    lambda {
      Proposal.close_early_proposals.should include(proposal)
    }.should change(Decision, :count).by(1)
    
    proposal.decision.should_not be_nil    
  end
  
  it "should close due proposals" do    
    proposal = Proposal.make(:proposer_member_id => @member.id, :close_date=>Time.now - 1.day)            
    Proposal.close_due_proposals.should include(proposal)
    
    proposal.reload
    proposal.should be_closed     
  end
  
  it "should send out an email to each member after a Proposal has been made" do
    Member.count.should >0
    
    p = Proposal.make(:proposer => @member)
  
    deliveries = Merb::Mailer.deliveries
    deliveries.size.should ==(Member.count)    
    
    mail = deliveries.first

    mail.to.should ==([@member.email])
    mail.from.should ==(["info@oneclickor.gs"])
#    mail.subject.first.should == ""         
  end

  it "should send out an email to each member after a Decision has been made" do
     Member.count.should >0

     p = Proposal.make(:proposer => @member)
     p.stub!(:passed?).and_return(true)
     p.close!
     
     Merb::Mailer.deliveries.size.should ==(Member.count*2)    

     mail = last_delivered_mail
     mail.from.should ==(["info@oneclickor.gs"])
#     mail.subject.first.should == ""
  end    
end