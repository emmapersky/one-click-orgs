require 'spec_helper'

describe "Multi-tenancy" do
  describe "when the app is newly installed" do
    it "should redirect all requests to the setup page" do
      get 'http://oneclickorgs.com/'
      response.should redirect_to('http://oneclickorgs.com/setup')
    end
    
    describe "visiting the setup page" do
      it "should show a form to set the base domain" do
        get 'http://oneclickorgs.com/setup'
        response.should have_selector("form[action='/setup/create_base_domain']") do |form|
          form.should have_selector("input[name='base_domain']")
          form.should have_selector("input[type=submit]")
        end
      end
      
      it "should auto-detect the base domain" do
        get 'http://oneclickorgs.com/setup'
        response.should have_selector("input[name='base_domain'][value='oneclickorgs.com']")
      end
    end
    
    describe "setting the base domain" do
      it "should save the base domain setting" do
        post 'http://oneclickorgs.com/setup/create_base_domain', :base_domain => 'oneclickorgs.com'
        Setting[:base_domain].should == 'oneclickorgs.com'
      end
      
      it "should redirect to the organisation setup page" do
        post 'http://oneclickorgs.com/setup/create_base_domain', :base_domain => 'oneclickorgs.com'
        response.should redirect_to '/organisations/new'
      end
    end
  end
  
  describe "after app setup" do
    before(:each) do
      Setting[:base_domain] = 'oneclickorgs.com'
    end
    
    it "should redirect all unrecognised subdomain requests back to the new organisation page" do
      get 'http://nonexistent.oneclickorgs.com/'
      response.should redirect_to 'http://oneclickorgs.com/organisations/new'
    end
    
    it "should redirect requests of the root url to the new organisation page" do
      get 'http://oneclickorgs.com/'
      response.should redirect_to 'http://oneclickorgs.com/organisations/new'
    end
    
    describe "visiting the new organisation page" do
      it "should show a form to set the subdomain for the new organisation" do
        get 'http://oneclickorgs.com/organisations/new'
        response.should have_selector("form[action='/organisations']") do |form|
          form.should have_selector("input[name='organisation[subdomain]']")
          form.should have_selector("input[type=submit]")
        end
      end
    end
    
    describe "creating a new organisation" do
      it "should create the organisation record" do
        post 'http://oneclickorgs.com/organisations', :organisation => {:subdomain => 'neworganisation'}
        Organisation.where(:subdomain => 'neworganisation').first.should_not be_nil
      end
      
      it "should redirect to the induction process for that domain" do
        post 'http://oneclickorgs.com/organisations', :organisation => {:subdomain => 'neworganisation'}
        response.should redirect_to 'http://neworganisation.oneclickorgs.com/induction/founder'
      end
    end
  end
  
  describe "with multiple organisations" do
    before(:each) do
      # Make three organisations, each with one member
      stub_organisation!(true, 'aardvarks', false, true).tap do |o|
        mc = o.member_classes.make
        o.members.make(:first_name => "Alvin", :email => 'alvin@example.com', :password => 'password', :password_confirmation => 'password', :member_class => mc)
      end
      
      stub_organisation!(true, 'beavers', false, true).tap do |o|
        mc = o.member_classes.make
        o.members.make(:first_name => "Betty", :email => 'betty@example.com', :password => 'password', :password_confirmation => 'password', :member_class => mc)
      end
      
      stub_organisation!(true, 'chipmunks', false, true).tap do |o|
        mc = o.member_classes.make
        o.members.make(:first_name => "Consuela", :email => 'consuela@example.com', :password => 'password', :password_confirmation => 'password', :member_class => mc)
      end
    end
    
    describe "logging in to a subdomain with a correct user" do
      it "should succeed" do
        get 'http://beavers.oneclickorgs.com/'
        response.should redirect_to 'http://beavers.oneclickorgs.com/login'
        post 'http://beavers.oneclickorgs.com/member_session', :email => 'betty@example.com', :password => 'password'
        response.should redirect_to 'http://beavers.oneclickorgs.com/'
        follow_redirect!
        response.body.should =~ /Welcome back, Betty/
      end
    end
    
    describe "logging into a subdomain with a user from a different subdomain" do
      it "should fail" do
        get 'http://aardvarks.oneclickorgs.com/'
        response.should redirect_to 'http://aardvarks.oneclickorgs.com/login'
        post 'http://aardvarks.oneclickorgs.com/member_session', :email => 'consuela@example.com', :password => 'password'
        response.body.should =~ /Email or password were incorrect/
      end
    end
    
    describe "accessing a nonexistent subdomain" do
      it "should redirect to the base domain" do
        get 'http://nonexistent.oneclickorgs.com/'
        response.should redirect_to 'http://oneclickorgs.com/organisations/new'
      end
    end
  end
end
