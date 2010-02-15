require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ChangeTextProposal do
  before(:each) do
    @objectives = Clause.set_text('objectives', 'eat all the cheese')
  end
  
  it "should use the constitution voting system" do
    Clause.set_text('constitution_voting_system', 'Veto')
    ChangeTextProposal.new.voting_system.should == VotingSystems::Veto
  end
  
  it "should change the objectives after successful proposal" do
    @p = ChangeTextProposal.new

    passed_proposal(@p, 'name'=>'objectives', 'value'=>'make all the yoghurt').
      should change(Clause, :count).by(1)
    
    Clause.get_text('objectives').should == 'make all the yoghurt'
  end
end