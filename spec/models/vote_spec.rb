require 'spec_helper'

describe Vote do
  before(:each) do
    @for_vote = Vote.create(:for => true)
    @against_vote = Vote.create(:for => false)
  end
  
  it "should store booleans as an integer" do
    @for_vote.for.should == 1
    @against_vote.for.should == 0
  end
  
  describe "for_or_against" do
    it "should return 'Support' for a 'for' vote" do
      @for_vote.for_or_against.should == "Support"
    end
    
    it "should return 'Oppose' for an 'against' vote" do
      @against_vote.for_or_against.should == "Oppose"
    end
  end
end
