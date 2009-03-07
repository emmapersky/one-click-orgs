require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Decision do
  before do
    Merb::Mailer.deliveries.clear
  end
  
  it "should selected closed early decsions" do
    member_0, member_1, member_2 = Member.make_n(3)
    member_3, member_4 = Member.make_n(2, :created_at => Time.now + 1.day) 
    
    proposal = Decision.create!(:proposer_member_id => member_1.id, :title => 'test')        
    
    
    member_0.cast_vote(:for, proposal.id)
    member_1.cast_vote(:for, proposal.id)
    member_2.cast_vote(:for, proposal.id)    
    
    Decision.find_closed_early_decisions.should include(proposal)
  end
  
  it "should send out an email after a decision has been made" do
    Merb.stub!(:run_later).and_return { |block| block.call }

    m = Member.make(:name => 'm1', :email => 'm1@blah.com', :created_at => Time.now - 1.day)
    Member.count.should ==(1)
    d = Decision.create!(:proposer_member_id => m.id, :title => 'test')
  
    deliveries = Merb::Mailer.deliveries
    deliveries.size.should ==(Member.count)    
    
    mail = deliveries.first
    mail.text.should match(/test/)
    mail.to.should ==([m.email])
    mail.from.should ==(["info@oneclickor.gs"])
  end
end