require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a proposal exists" do
  Proposal.all.destroy!  
  login    
  request(resource(:proposals), :method => "POST", 
    :params => { :proposal => 
        { :id => nil, :proposer_member_id => Member.first.id, :title=>'proposal' }
               })   
end

describe "everything" do
  before do 
    login
  end
  
  describe "resource(@proposal)", :given => "a proposal exists" do
  
    describe "GET" do
      before(:each) do
        @response = request(resource(Proposal.first))
      end
  
      it "responds successfully" do
        @response.should be_successful
      end
    end
  
  end
end

