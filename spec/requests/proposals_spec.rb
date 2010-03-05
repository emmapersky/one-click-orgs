require 'spec_helper'

module ProposalsSpecHelper
  def a_proposal_exists
    Proposal.destroy_all
    login
    post(proposals_path, {:proposal => {:id => nil, :proposer_member_id => Member.first.id, :title => 'proposal'}})
  end
end

describe "everything" do
  include ProposalsSpecHelper
  
  before do 
    login
  end
  
  describe "/proposals/1, given a proposal exists" do
    before(:each) do
      a_proposal_exists
    end
    
    describe "GET" do
      before(:each) do
        get(proposal_path(Proposal.first))
      end
  
      it "responds successfully" do
        @response.should be_successful
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

