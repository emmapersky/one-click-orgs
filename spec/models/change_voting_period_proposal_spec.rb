require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ChangeVotingPeriodProposal do

  before do
    @current_voting_period = Clause.create!(:name=>'voting_period', :integer_value=>300)
  end
  
  it "should change voting period after successful proposal" do
    @p = ChangeVotingPeriodProposal.new
    @p.stub!(:passed?).and_return(true)
    Constitution.should_receive(:change_voting_period).with(86400)
    @p.enact!('new_voting_period'=>86400)
  end
end