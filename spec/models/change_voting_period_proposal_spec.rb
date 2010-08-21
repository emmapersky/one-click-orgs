require 'spec_helper'

describe ChangeVotingPeriodProposal do

  before do
    stub_organisation!
    @current_voting_period = @organisation.clauses.set_integer('voting_period', 300)
  end
  
  it "should change voting period after successful proposal" do
    @p = @organisation.change_voting_period_proposals.new
    Clause.should_receive(:set_integer).with('voting_period', 86400)
    passed_proposal(@p, 'new_voting_period'=>86400).call
  end
end