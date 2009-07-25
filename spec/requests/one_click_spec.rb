require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/one_click" do
  before(:each) do
    @response = request("/one_click")
    Constitution.stub!(:voting_system).and_return(VotingSystems.get(:RelativeMajority))        
    # Constitution.stub!(:organisation_name).and_return("Test") # TODO should be in spec_helper, default            
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

      puts @response.body if @response.status != 302
      
      @response.should redirect_to("/one_click/control_centre")
      
      ChangeVotingSystemProposal.count.should == 1      
      ChangeVotingSystemProposal.all.first.title.should == 'change general voting system to Supporting votes from every single member'
    end
  end
end