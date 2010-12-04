require 'spec_helper'

describe AddMemberProposal do
  before do
    stub_constitution!
    stub_organisation!
  end


  it "should persist type information" do    
    @proposal = @organisation.add_member_proposals.make
    @organisation.add_member_proposals.find(@proposal.id).should be_kind_of(AddMemberProposal)
  end
  
  it "should send an email to the new member if proposal passes" do
    @proposal = @organisation.add_member_proposals.new
    Member.should_receive(:create_member).with(hash_including(:first_name=>"Paul"), true)
    @proposal.enact!(:first_name=>"Paul")
  end
  
  it "should not validate when proposed new member is already active" do
    @existing_member = @organisation.members.make
    @proposal = @organisation.add_member_proposals.build(:parameters => {'email' => @existing_member.email})
    @proposal.should_not be_valid
  end
end