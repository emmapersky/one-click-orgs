require 'spec_helper'

describe ChangeVotingSystemProposal do
  before do
    stub_organisation!
    @constitution_voting_system = @organisation.clauses.set_text('constitution_voting_system', 'RelativeMajority')        
    @proposed_system = 'Unanimous'
  end
  
  it "should change voting system after successful proposal" do
    @p = @organisation.change_voting_system_proposals.new

    Clause.should_receive(:set_text).with('constitution_voting_system', 'Unanimous')
    passed_proposal(@p, 'type'=>'constitution', 'proposed_system'=>@proposed_system).call
  end
end
