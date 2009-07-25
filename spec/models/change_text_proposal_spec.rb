require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ChangeTextProposal do
  before(:each) do
    @objectives = Clause.create!(:name => 'objectives', :text_value => "eat all the cheese")
  end
  
  it "should use the constitution voting system" do
    Clause.create!(:name => 'constitution_voting_system', :text_value => 'Veto')
    ChangeTextProposal.new.voting_system.should == VotingSystems::Veto
  end
  
  it "should change the objectives after successful proposal" do
    @p = ChangeTextProposal.new(:parameters=>{'name'=>'objectives', 'value'=>'make all the yoghurt'}.to_json)
    @p.stub!(:passed?).and_return(true)
    lambda {
      @p.enact!
    }.should change(Clause, :count).by(1)
    Clause.get_current('objectives').text_value.should == 'make all the yoghurt'
  end
end