require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/one_click" do
  before(:each) do
    stub_constitution!
    stub_organisation!
  end
  
  describe "proposing text amendments" do
    before(:each) do
      login
      @proposal = mock('proposal', :save => true)
    end
    
    it "should create a proposal to change the organisation name" do
      ChangeTextProposal.should_receive(:serialize_parameters).with(
        'name' => 'organisation_name',
        'value' => 'The Yoghurt Yurt'
      ).and_return(@serialized_parameters = mock('serialized_parameters'))
      
      ChangeTextProposal.should_receive(:new).with(
        :title => "Change organisation_name to 'The Yoghurt Yurt'",
        :parameters => @serialized_parameters,
        :proposer_member_id => @user.id
      ).and_return(@proposal)
      
      @response = request(
        url(:controller => 'one_click', :action => 'propose_text_amendment'),
        :method => 'POST',
        :params => {'name' => 'organisation_name', 'value' => 'The Yoghurt Yurt'}
      )
      
      @response.should redirect_to('/one_click/control_centre')
    end
    
    it "should create a proposal to change the objectives" do
      ChangeTextProposal.should_receive(:serialize_parameters).with(
        'name' => 'objectives',
        'value' => 'make all the yoghurt'
      ).and_return(@serialized_parameters = mock('serialized_parameters'))
      
      ChangeTextProposal.should_receive(:new).with(
        :title => "Change objectives to 'make all the yoghurt'",
        :parameters => @serialized_parameters,
        :proposer_member_id => @user.id
      ).and_return(@proposal)
      
      @response = request(
        url(:controller => 'one_click', :action => 'propose_text_amendment'),
        :method => 'POST',
        :params => {'name' => 'objectives', 'value' => 'make all the yoghurt'}
      )
      
      @response.should redirect_to('/one_click/control_centre')
    end
    
    it "should create a proposal to change the domain" do
      ChangeTextProposal.should_receive(:serialize_parameters).with(
        'name' => 'domain',
        'value' => 'yaourt.com'
      ).and_return(@serialized_parameters = mock('serialized_parameters'))
      
      ChangeTextProposal.should_receive(:new).with(
        :title => "Change domain to 'yaourt.com'",
        :parameters => @serialized_parameters,
        :proposer_member_id => @user.id
      ).and_return(@proposal)
      
      @response = request(
        url(:controller => 'one_click', :action => 'propose_text_amendment'),
        :method => 'POST',
        :params => {'name' => 'domain', 'value' => 'yaourt.com'}
      )
      
      @response.should redirect_to('/one_click/control_centre')
    end
  end
  
  describe "proposing voting system amendments" do
    before do
      login
      @general_voting_system = Clause.set_text('general_voting_system', 'RelativeMajority')
      @membership_voting_system = Clause.set_text('membership_voting_system', 'RelativeMajority')
      @constitution_voting_system = Clause.set_text('constitution_voting_system', 'RelativeMajority')
    end
    
    describe "for general decisions" do
      it "should add the proposal" do
        @response = request(url(:controller=>'one_click', 
          :action=>'propose_voting_system_amendment'),
          :method=>'POST', :params=>{:general_voting_system=>'Unanimous'})

        puts @response.body if @response.status != 302

        @response.should redirect_to("/one_click/control_centre")
      
        ChangeVotingSystemProposal.count.should == 1
        ChangeVotingSystemProposal.all.first.title.should == 'change general voting system to Supporting votes from every single member'
        proposal_parameters = ActiveSupport::JSON.decode(ChangeVotingSystemProposal.all.first.parameters)
        proposal_parameters['type'].should == 'general'
        proposal_parameters['proposed_system'].should == 'Unanimous'
      end
    end
    
    describe "for membership decisions" do
      it "should add the proposal" do
        @response = request(url(:controller=>'one_click', 
          :action=>'propose_voting_system_amendment'),
          :method=>'POST', :params=>{:membership_voting_system=>'Veto'})

        puts @response.body if @response.status != 302

        @response.should redirect_to("/one_click/control_centre")
      
        ChangeVotingSystemProposal.count.should == 1
        ChangeVotingSystemProposal.all.first.title.should == 'change membership voting system to No opposing votes'
        proposal_parameters = ActiveSupport::JSON.decode(ChangeVotingSystemProposal.all.first.parameters)
        proposal_parameters['type'].should == 'membership'
        proposal_parameters['proposed_system'].should == 'Veto'
      end
    end
    
    describe "for constitution decisions" do
      it "should add the proposal" do
        @response = request(url(:controller=>'one_click', 
          :action=>'propose_voting_system_amendment'),
          :method=>'POST', :params=>{:constitution_voting_system=>'AbsoluteMajority'})

        puts @response.body if @response.status == 500
        @response.should redirect_to("/one_click/control_centre")
      
        ChangeVotingSystemProposal.count.should == 1
        ChangeVotingSystemProposal.all.first.title.should == 'change constitution voting system to Supporting votes from more than half the members'
        proposal_parameters = ActiveSupport::JSON.decode(ChangeVotingSystemProposal.all.first.parameters)
        proposal_parameters['type'].should == 'constitution'
        proposal_parameters['proposed_system'].should == 'AbsoluteMajority'
      end
    end
    
    describe "voting period amendments" do
      it "should add the proposal" do
        @response = request(url(:controller=>'one_click', 
          :action=>'propose_voting_period_amendment'),
          :method=>'POST', :params=>{:new_voting_period=>'86400'})

        puts @response.body if @response.status == 500
        @response.should redirect_to("/one_click/control_centre")

        ChangeVotingPeriodProposal.count.should == 1
        ChangeVotingPeriodProposal.all.first.title.should == 'Change voting period to 24 hours'
        proposal_parameters = ActiveSupport::JSON.decode(ChangeVotingPeriodProposal.all.first.parameters)
        proposal_parameters['new_voting_period'].to_i.should == 86400
      end
    end
  end
  
  describe "timeline" do
    before(:each) do
      login
    end
    
    it "should display a timeline with past events" do
      Member.make_n(10) 
      Decision.make_n(10)
      Proposal.make_n(10)
      
      @response = request(url(:controller=>'one_click', :action=>'timeline'))
      @response.should be_successful
      @response.should have_xpath("//table[@class='timeline']")
    end
  end
end