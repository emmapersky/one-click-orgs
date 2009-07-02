require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ChangeVotingSystemProposal do

  before do
    @constitution_voting_system = Clause.create!(:name=>'constitution_voting_system', :text_value=>'RelativeMajority')        
    @proposed_system = 'Unanimous'
  end
  
  it "should change voting system after successful proposal" do
    @p = ChangeVotingSystemProposal.new(:parameters=>{'type'=>'constitution', 'proposed_system'=>@proposed_system}.to_json)
    @p.stub!(:passed?).and_return(true)
    @p.enact!        
    Clause.first(:name=>'constitution_voting_system').text_value.should == @proposed_system
  end
end