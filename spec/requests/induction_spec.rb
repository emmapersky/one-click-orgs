require 'spec_helper'

describe "induction process" do
  before(:each) do
    stub_setup!
    Organisation.stub!(:find_by_host).and_return(@organisation = Organisation.make)
  end
  
  # This is just a very rough spec of the entire induction process, to make sure that this key flow
  # isn't inadvertently broken.
  # 
  # This kind of thing would be better done in Cucumber with Webrat so that it's more readable and less brittle.
  
  before(:each) do
    @member_class = MemberClass.make
  end
  
  it "should work" do
    get '/'
    
    follow_redirect!
    response.should have_selector("form[action='/induction/create_founder']")
    
    post '/induction/create_founder', :member => {:email => "bob@example.com", :first_name => "Bob", :last_name => "Smith", :password => "letmein", :password_confirmation => "letmein", :member_class_id => @member_class.id}
    
    follow_redirect!
    
    response.should have_selector("form[action='/induction/create_organisation_details']")
    
    post '/induction/create_organisation_details', :organisation_name => "The Yak Shack", :objectives => "rehabilitating yaks.", :assets => '1'
    
    follow_redirect!
    response.should have_selector("form[action='/induction/create_members']")
    
    post '/induction/create_members', 'members' => {'0' => {'id' => '', 'first_name' => "Erin", 'last_name' => "Baker", 'email' => "erin@example.com", 'member_class_id' => @member_class.id }}
    
    @organisation.members.count.should == 2
    
    second_member_id = Member.last.id
    
    follow_redirect!
    response.should have_selector("form[action='/induction/create_voting_settings']")
    
    post '/induction/create_voting_settings', "constitution_voting_system"=>"RelativeMajority", "voting_period"=>"1800", "general_voting_system"=>"RelativeMajority", "membership_voting_system"=>"RelativeMajority"
    
    follow_redirect!
    response.should have_selector("a[href='/induction/founding_meeting_details']")
    
    get '/induction/founding_meeting_details'
    response.should have_selector("form[action='/induction/create_founding_meeting_details']")
    
    post '/induction/create_founding_meeting_details', "location"=>"The Horse and Cart", "time"=>"6pm", "date"=>"1 April 2010"
    
    follow_redirect!
    response.should have_selector("a[href='/induction/confirm_agenda']")
    
    get('/induction/confirm_agenda')
    follow_redirect!
    response.should have_selector("form[action='/induction/confirm_founding_meeting']") do |form|
      form.should have_selector("input[type=submit][data-confirm]")
    end
    
    post '/induction/confirm_founding_meeting', :members => {second_member_id.to_s => '1'}
    response.should redirect_to '/one_click/dashboard'
    
    @organisation = Organisation.first
    @organisation.active?.should be_true
    @organisation.members.count.should == 2
    @organisation.organisation_name.should == "The Yak Shack"
    @organisation.objectives.should == "rehabilitating yaks."
    @organisation.assets.should be_true
    @organisation.constitution.voting_period.should == 1800
    @organisation.constitution.voting_system(:general).should == VotingSystems::RelativeMajority
    @organisation.constitution.voting_system(:membership).should == VotingSystems::RelativeMajority
    @organisation.constitution.voting_system(:constitution).should == VotingSystems::RelativeMajority
  end
  
  it "should automatically log the initial user in" do
    get '/induction/founder'
    post '/induction/create_founder', :member => {:email => "bob@example.com", :first_name => "Bob", :last_name => "Smith", :password => "letmein", :password_confirmation => "letmein"}
    follow_redirect!
    response.should have_selector("div.control_bar") do |control_bar|
      control_bar.should have_selector("a[href='/member_session'][data-method=delete]")
    end
  end
  
  describe "guarding access based on state" do
    describe "when organisation is under construction" do
      before do
        organisation_is_under_construction
      end
      
      it "should allow creation of founding member if no members exist and organisation is under contruction" do
        @organisation.stub!(:has_founding_member?).and_return(false)
        
        get url_for(:controller=>'induction', :action=>'founder')
        @response.should be_successful
      end
      
      it "should always redirect to the create founder page if organisation under construction and no founding members present in the system" do
        @organisation.stub!(:has_founding_member?).and_return(false)
        
        get('/one_click')
        @response.should redirect_to(:controller=>'induction', :action=>'founder')
      end
    end
    
    describe "when organisation is pending" do
      before(:each) do
        login
        organisation_is_pending
      end
      
      it "should always redirect to founding meeting page if organisation is in pending state" do
        get('/one_click')
        @response.should redirect_to(:controller=>'induction', :action=> 'founding_meeting')
      end
    end
    
    describe "when organisation is active" do
      before do
        organisation_is_active
      end
      
      it "should require login if organisation is active and not logged in" do
        @organisation.stub!(:has_founding_member?).and_return(true)      
        get('/one_click')
        response.should redirect_to(login_path)
      end
      
      it "should redirect to dashboard if organisation is active and any induction action is requested" do
        login
        
        (InductionController::CONSTRUCTION_ACTIONS + InductionController::PENDING_ACTIONS).each do |a|
          get url_for(:controller=>'induction', :action=>a)
          @response.should redirect_to(:controller=>'one_click', :action=>'dashboard')
        end
      end
    end
  end
  
  # it "should detect the domain" do
  #   organisation_is_under_construction
  #   @organisation.domain.should be_blank
  #   post("/induction/create_founder", {:member => {:first_name => "Bob", :last_name => "Smith", :email => "bob@example.com", :password => "qwerty", :password_confirmation => "qwerty"}})
  #   @organisation.domain.should == "http://www.example.com"
  # end
end
