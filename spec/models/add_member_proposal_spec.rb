require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe AddMemberProposal do
  before do
    stub_constitution!
  end

  it "should persist type information" do    
    @proposal = AddMemberProposal.make
    AddMemberProposal.get(@proposal.id).should be_kind_of(AddMemberProposal)
  end
end