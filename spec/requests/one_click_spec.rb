require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/one_click" do
  before(:each) do
    @response = request("/one_click")
    Constitution.stub!(:voting_system).and_return(VotingSystems.get(:RelativeMajority))        
    # Constitution.stub!(:organisation_name).and_return("Test") # TODO should be in spec_helper, default            
  end
  
  
  describe "proposing voting system amendments" do
    before do
      login
      @general_voting_system = Clause.create!(:name=>'general_voting_system', :text_value=>'RelativeMajority')
      @membership_voting_system = Clause.create!(:name => 'membership_voting_system', :text_value => 'RelativeMajority')
      @constitution_voting_system = Clause.create!(:name => 'constitution_voting_system', :text_value => 'RelativeMajority')
    end
    
    describe "for general decisions" do
      it "should add the proposal" do
        @response = request(url(:controller=>'one_click', 
          :action=>'propose_amendment'),
          :method=>'POST', :params=>{:general_voting_system=>'Unanimous'})

        puts @response.body if @response.status != 302

        @response.should redirect_to("/one_click/control_centre")
      
        ChangeVotingSystemProposal.count.should == 1
        ChangeVotingSystemProposal.all.first.title.should == 'change general voting system to Supporting votes from every single member'
        proposal_parameters = YAML.JSON(ChangeVotingSystemProposal.all.first.parameters)
        proposal_parameters['type'].should == 'general'
        proposal_parameters['proposed_system'].should == 'Unanimous'
      end
    end
    
    describe "for membership decisions" do
      it "should add the proposal" do
        @response = request(url(:controller=>'one_click', 
          :action=>'propose_amendment'),
          :method=>'POST', :params=>{:membership_voting_system=>'Veto'})

        puts @response.body if @response.status != 302

        @response.should redirect_to("/one_click/control_centre")
      
        ChangeVotingSystemProposal.count.should == 1
        ChangeVotingSystemProposal.all.first.title.should == 'change membership voting system to No opposing votes'
        proposal_parameters = YAML.JSON(ChangeVotingSystemProposal.all.first.parameters)
        proposal_parameters['type'].should == 'membership'
        proposal_parameters['proposed_system'].should == 'Veto'
      end
    end
    
    describe "for constitution decisions" do
      it "should add the proposal" do
        @response = request(url(:controller=>'one_click', 
          :action=>'propose_amendment'),
          :method=>'POST', :params=>{:constitution_voting_system=>'AbsoluteMajority'})

        puts @response.body if @response.status == 500
        @response.should redirect_to("/one_click/control_centre")
      
        ChangeVotingSystemProposal.count.should == 1
        ChangeVotingSystemProposal.all.first.title.should == 'change constitution voting system to Supporting votes from more than half the members'
        proposal_parameters = YAML.JSON(ChangeVotingSystemProposal.all.first.parameters)
        proposal_parameters['type'].should == 'constitution'
        proposal_parameters['proposed_system'].should == 'AbsoluteMajority'
      end
    end
    
    
  end
end