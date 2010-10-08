require 'spec_helper'

describe ChangeTextProposal do
  before(:each) do
    stub_organisation!
    @objectives = @organisation.clauses.set_integer('voting_period', 30*60)
    @objectives = @organisation.clauses.set_text('objectives', 'eat all the cheese')
  end
  
  it "should use the constitution voting system" do
    @organisation.clauses.set_text('constitution_voting_system', 'Veto')
    @organisation.change_text_proposals.new.voting_system.should == VotingSystems::Veto
  end
  
  it "should change the objectives after successful proposal" do
    @p = @organisation.change_text_proposals.new
    
    passed_proposal(@p, 'name'=>'objectives', 'value'=>'make all the yoghurt').
      should change(@organisation.clauses, :count).by(1)
    
    @organisation.clauses.get_text('objectives').should == 'make all the yoghurt'
  end
  
  it "should not validate if text has not been changed" do
    @p = ChangeTextProposal.new(:proposer => Member.make, :title => "change objectives to eat all the cheese", :parameters => {'name' => 'objectives', 'value' => 'eat all the cheese'})
    @p.should_not be_valid
  end
end
