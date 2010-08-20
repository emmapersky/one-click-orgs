require 'spec_helper'

describe "/one_click" do
  before(:each) do
    stub_constitution!
    stub_organisation!
  end
  
  describe "timeline" do
    before(:each) do
      login
    end
    
    it "should display a timeline with past events" do
      @organisation.members.make_n(10) 
      @organisation.proposals.make_n(10)
      @organisation.proposals.make_n(10).each{|p| p.create_decision}
      
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
        @proposal = @organisation.add_member_proposals.create!(
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