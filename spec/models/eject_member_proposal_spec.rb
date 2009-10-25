require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe EjectMemberProposal do
  before { stub_constitution! }
    
  it "should use the membership voting system" do
    Clause.set_text('membership_voting_system', 'Veto')
    EjectMemberProposal.new.voting_system.should == VotingSystems::Veto
  end
  
  it "should eject the member after passing, disabling the account" do
    @m = Member.make    
    
    @p = EjectMemberProposal.new(:parameters=> {'id' => @m.id }.to_json)
    @m.should be_active
    passed_proposal(@p).call
    
    #FIXME make proposals more testable by avoiding loading of models
    #@m.should_receive(:eject!)
    
    @m.reload
    @m.should_not be_active
  end  
end
