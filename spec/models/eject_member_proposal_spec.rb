require 'spec_helper'

describe EjectMemberProposal do
  before do 
    stub_constitution!
    stub_organisation!
  end
    
  it "should use the membership voting system" do
    @organisation.clauses.set_text('membership_voting_system', 'Veto')
    @organisation.eject_member_proposals.new.voting_system.should == VotingSystems::Veto
  end
  
  it "should eject the member after passing, disabling the account" do
    @m = @organisation.members.make    
    
    @p = @organisation.eject_member_proposals.new(:parameters=> {'id' => @m.id }.to_json)
    @m.should be_active
    passed_proposal(@p).call
    
    #FIXME make proposals more testable by avoiding loading of models
    #@m.should_receive(:eject!)
    
    @m.reload
    @m.should_not be_active
  end  
end
