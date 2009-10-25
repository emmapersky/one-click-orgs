require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe AddMemberProposal do
  before do
    stub_constitution!
  end

  it "should persist type information" do    
    @proposal = AddMemberProposal.make
    AddMemberProposal.get(@proposal.id).should be_kind_of(AddMemberProposal)
  end
  
  it "should send an email to the new member if proposal passes" do
    @proposal = AddMemberProposal.new
    Member.should_receive(:create_member).with(hash_including(:name=>"Paul"), true)
    @proposal.enact!(:name=>"Paul")    
  end
end