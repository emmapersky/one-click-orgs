require 'spec_helper'

describe "everything" do
  before(:each) do 
    @user = login
    @proposal = @organisation.proposals.make
  end
      
  describe "vote casting" do
    it "should cast a 'for' vote" do
      post(vote_for_path(:id => @proposal.id), {:return_to => '/foo'})
      response.should redirect_to '/foo'
      @proposal.vote_by(@user).for?.should be_true
    end
  
    it "should cast an 'against' vote" do
      post(vote_against_path(:id => @proposal.id), {:return_to => '/foo'})
      response.should redirect_to '/foo'
      @proposal.vote_by(@user).for?.should be_false
    end
  end
end
