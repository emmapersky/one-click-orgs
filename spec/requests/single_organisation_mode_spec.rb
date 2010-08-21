require 'spec_helper'

describe "Single-organisation mode" do
  describe "instance setup" do
    it "shows a button to run the app in single-organisation mode" do
      get 'http://oneclickorgs.com/setup'
      response.should have_selector("form", :action => '/setup/set_single_organisation_mode') do |form|
        form.should have_selector('input', :type => 'submit')
      end
    end
    
    it "puts the app into single-organisation mode" do
      post 'http://oneclickorgs.com/setup/set_single_organisation_mode'
      Setting[:single_organisation_mode].should == 'true'
    end
    
    it "creates an organisation" do
      Organisation.count.should == 0
      post 'http://oneclickorgs.com/setup/set_single_organisation_mode'
      Organisation.count.should == 1
      Organisation.last.subdomain.should be_blank
    end
    
    it "successfully redirects to the induction process at the same host" do
      post 'http://oneclickorgs.com/setup/set_single_organisation_mode'
      response.should redirect_to('http://oneclickorgs.com/induction/founder')
      get 'http://oneclickorgs.com/induction/founder'
      response.should be_successful
    end
  end
  
  describe "day-to-day running of the instance" do
    before(:each) do
      Setting[:single_organisation_mode] = 'true'
      
      # TODO: Roll stubbing of single-organisation-mode organisations into stubs.rb
      @organisation = Organisation.make(:subdomain => nil)
      @organisation.clauses.set_text('organisation_state', "active")
      
      @member_class = @organisation.member_classes.make
      
      @member = @organisation.members.make(:member_class => @member_class)
      @member.password = @member.password_confirmation = "password"
      @member.save!
    end
    
    it "allows login" do
      post "http://oneclickorgs.com/member_session", :email => @member.email, :password => 'password'
      response.should redirect_to('/')
      
      get 'http://oneclickorgs.com/'
      response.should be_successful
      response.body.should contain "Dashboard"
    end
    
    # TODO: More tests needed here?
  end
end
