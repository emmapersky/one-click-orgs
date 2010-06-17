require 'spec_helper'

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
        :title => "Change organisation name to 'The Yoghurt Yurt'",
        :parameters => @serialized_parameters,
        :proposer_member_id => @user.id
      ).and_return(@proposal)
      
      post(url_for(:controller => 'proposals', :action => 'create_text_amendment'), {'name' => 'organisation_name', 'value' => 'The Yoghurt Yurt'})

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
      
      post(url_for(:controller => 'proposals', :action => 'create_text_amendment'), {'name' => 'objectives', 'value' => 'make all the yoghurt'})
      
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
      
      post(url_for(:controller => 'proposals', :action => 'create_text_amendment'), {'name' => 'domain', 'value' => 'yaourt.com'})
      
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
        post(url_for(:controller => 'proposals', :action => 'create_voting_system_amendment'), {:general_voting_system => 'Unanimous'})

        puts @response.body if @response.status != 302

        @response.should redirect_to("/one_click/control_centre")
      
        ChangeVotingSystemProposal.count.should == 1
        ChangeVotingSystemProposal.first.title.should == 'change general voting system to Supporting votes from every single member'
        proposal_parameters = ActiveSupport::JSON.decode(ChangeVotingSystemProposal.all.first.parameters)
        proposal_parameters['type'].should == 'general'
        proposal_parameters['proposed_system'].should == 'Unanimous'
      end
    end
    
    describe "for membership decisions" do
      it "should add the proposal" do
        post(url_for(:controller=>'proposals', :action=>'create_voting_system_amendment'), {:membership_voting_system=>'Veto'})

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
        post(url_for(:controller=>'proposals', :action=>'create_voting_system_amendment'), {:constitution_voting_system=>'AbsoluteMajority'})

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
        post(url_for(:controller=>'proposals', :action=>'create_voting_period_amendment'), {:new_voting_period=>'86400'})

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
      
      get url_for(:controller => 'one_click', :action => 'timeline')
      @response.should be_successful
      @response.should have_xpath("//table[@class='timeline']")
    end
  end
  
  describe "control centre" do
    before(:each) do
      login
    end
    
    describe "with an 'add member' proposal recently decided" do
      before(:each) do
        @proposal = AddMemberProposal.create!(
          :title => "Add new member",
          :proposer_member_id => default_user.id,
          :parameters => AddMemberProposal.serialize_parameters(:email => "new@example.com", :name => "James Nouveau")
        )
        @proposal.open = false
        @proposal.close_date = Time.now.utc
        @proposal.accepted = true
        @proposal.save!
        Decision.create!(:proposal_id => @proposal.id)
      end
      
      # GH-89
      it "should display a link to the recently-closed 'add member' proposal" do
        get url_for(:controller => 'one_click', :action => 'control_centre')
        response.should have_selector("table.decisions a[href='/proposals/#{@proposal.id}']")
      end
    end
  end
end