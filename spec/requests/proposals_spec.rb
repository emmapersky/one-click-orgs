require 'spec_helper'

module ProposalsSpecHelper
  def a_proposal_exists
    Proposal.destroy_all
    login
    post(proposals_path, {:proposal => {:id => nil, :proposer_member_id => Member.first.id, :title => 'proposal'}})
    @proposal = Proposal.first
  end
end

describe "everything" do
  include ProposalsSpecHelper
  
  before(:each) do 
    stub_organisation!
    stub_constitution!
    default_user
    login
  end
  
  describe "/proposals/1, given a proposal exists" do
    before(:each) do
      @member_two = Member.make
      @member_three = Member.make
      a_proposal_exists
      
    end
    
    describe "GET" do
      before(:each) do
        default_user.cast_vote(:for, @proposal.id)
        @member_two.cast_vote(:for, @proposal.id)
        @member_three.cast_vote(:against, @proposal.id)

        get(proposal_path(@proposal))
      end
  
      it "responds successfully" do
        @response.should be_successful
      end
      
      it "should display the correct vote count" do
        response.should contain /2\s*\/\s*1/ # i.e. "2/1" with arbitrary whitespace
      end
    end
  end
  
  describe "/proposals, given a proposal exists"  do
    before(:each) do
      a_proposal_exists
    end
    
     describe "GET" do
       before(:each) do
         get(proposals_path)
       end

       it "responds successfully" do
         @response.should be_successful
       end

       it "contains a list of proposals" do
         # pending
         @response.should have_xpath("//ul")
       end
     end
  end
end

