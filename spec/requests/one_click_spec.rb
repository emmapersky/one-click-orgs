require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/one_click" do
  before(:each) do
    @response = request("/one_click")
  end
  
  
  describe "propose amendment" do
    before do
      login
      @general_voting_system = Clause.create!(:name=>'general_voting_system', :text_value=>'RelativeMajority')        
    end
    
    
    it "should add a proposal" do      
      @response = request(url(:controller=>'one_click', 
        :action=>'propose_amendment'),
        :method=>'POST', :params=>{:general_voting_system=>'Unanimous'})

      puts @response.body if @response.status == 500
      @response.should redirect_to("/constitution")
      
      ChangeVotingSystemProposal.count.should == 1      
      ChangeVotingSystemProposal.all.first.title.should == 'change general voting system to Unanimous'
    end
  end
end