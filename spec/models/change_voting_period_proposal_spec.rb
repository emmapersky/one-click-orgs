require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ChangeVotingPeriodProposal do

  before do
    @current_voting_period = Clause.create!(:name=>'voting_period', :integer_value=>300)
  end
  
  it "should change voting period after successful proposal" do
    @p = ChangeVotingPeriodProposal.new
    Constitution.should_receive(:change_voting_period).with(86400)
    passed_proposal(@p, 'new_voting_period'=>86400).call
  end
end