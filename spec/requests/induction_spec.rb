require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/induction" do
  
  describe "initial creation" do
    before do
      organisation_is_under_construction
    end
    
    it "should allow creation of founding member if no members exist and organisation is under contruction" do
      Organisation.stub!(:has_founding_member?).and_return(false)
      
      @response = request(url(:controller=>'induction', :action=>'founder'))
      @response.should be_successful
    end
  
    it "should always redirect to the create founder page if organisation under construction and no founding members present in the system" do
      Organisation.stub!(:has_founding_member?).and_return(false)
      
      @response = request('/one_click')
      @response.should redirect_to(url(:controller=>'induction', :action=>'founder'))
    end
  end
  
  describe "pending state (constitution has been setup, emails have been sent)" do
    before do
      login      
      organisation_is_pending
    end
    
    it "should always redirect to founding meeting page if organisation is in pending state" do    
      @response = request('/one_click')
      @response.should redirect_to(url(:controller=>'induction', :action=> 'founding_meeting'))
    end      
  end
  
  
  describe "active state (founding meeting has been confirmed)" do
    
    before do
      organisation_is_active
    end
    
    it "should require login if organisation is active and not logged in" do
      Organisation.stub!(:has_founding_member?).and_return(true)      
      @response = request('/one_click')
      @response.status.should == 401
    end
    
    it "should redirect to control centre if organisation is active and any induction action is requested" do
      login
      
      (Induction::CONSTRUCTION_ACTIONS + Induction::PENDING_ACTIONS).each do |a|
        @response = request(url(:controller=>'induction', :action=>a))
        @response.should redirect(url(:controller=>'one_click', :action=>'control_centre'))
      end      
    end
  end
  
  it "should detect the domain" do
    organisation_is_under_construction
    Constitution.domain.should be_blank
    request("/induction/create_founder", :method => "POST", :params => {:member => {:name => "Bob Smith", :email => "bob@example.com", :password => "qwerty", :password_confirmation => "qwerty"}})
    Constitution.domain.should == "http://example.org"
  end
end