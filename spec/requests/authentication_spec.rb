require 'spec_helper'

describe "authentication" do
  before(:each) do
    default_user
  end
  
  describe "getting login form" do
    it "should display a login form" do
      get '/login'
      response.should have_selector("form[action='/member_session']")
    end
  end
  
  describe "logging in" do
    before(:each) do
      post member_session_path, :email => 'krusty@clown.com', :password => 'password'
    end
    
    it "should log in the user" do
      session[:user].should == (Member.last.id)
    end
    
    it "should redirect to the home page" do
      response.should redirect_to('/')
    end
  end
  
  describe "trying to log in with bad credentials" do
    before(:each) do
      post member_session_path, :email => 'krusty@clown.com', :password => 'wrongpassword'
    end
    
    it "should not log in the user" do
      session[:user].should be_nil
    end
    
    it "should render the login form" do
      response.should have_selector("form[action='/member_session']")
    end
    
    it "should set an error flash" do
      flash[:error].should_not be_blank
    end
  end
  
  describe "logging out" do
    before(:each) do
      post member_session_path, :email => 'krusty@clown.com', :password => 'password'
      delete member_session_path
    end
    
    it "should log out the user" do
      session[:user].should be_nil
    end
    
    it "should redirect to the home page" do
      response.should redirect_to('/')
    end
  end
end
