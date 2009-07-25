require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe EjectMemberProposal do
  it "should use the membership voting system" do
    Clause.create!(:name => 'membership_voting_system', :text_value => 'Veto')
    EjectMemberProposal.new.voting_system.should == VotingSystems::Veto
  end
  
  it "should eject the member after passing" do
    @m = Member.create!(:name => "Bob Smith", :email => "bob@example.com")
    
    @p = EjectMemberProposal.new(:parameters=>{'id' => @m.id}.to_json)
    
    @p.stub!(:passed?).and_return(true)
    lambda {
      @p.enact!        
    }.should change(Member, :count).by(-1)
    
    Member.first(:id => @m.id).should be_nil
  end
end
