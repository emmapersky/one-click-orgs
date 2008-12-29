require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Member do
  
  before(:each) do
    @member = Member.create(:name => "Dana Scully", :email => "scully@fbi.com")
    @proposal = Decision.create(:title => "something spooky", :proposer_member_id => @member.id)
  end
  
  it "should not allow votes on members created before proposals" do
    new_member = Member.create(:name => "Fox Mulder", :email => "mulder@fbi.com", :created_at => Time.now + 1.day)
    
    
    lambda {
      new_member.cast_vote(:for, @proposal.id)
    }.should raise_error VoteError
  end

  it "should not allow additional votes" do
    @member.cast_vote(:for, @proposal.id)
    
    lambda {
      @member.cast_vote(:against, @proposal.id)
    }.should raise_error VoteError
  end
  
end