require 'spec_helper'

describe MemberSessionsController do
  before(:each) do
    stub_constitution!
    stub_organisation!
  end
  
  describe "GETting new" do
    it "should render the 'new' template" do
      get :new
      response.should render_template('member_sessions/new')
    end
  end
  
  describe "POSTing create" do
    before(:each) do
      @user = mock_model(Member)
    end
    
    it "should check the credentials" do
      Member.should_receive(:authenticate).with("chris@example.com", 'goodpassword').and_return(@user)
      post_create
    end
  
    describe "with good credentials" do
      before(:each) do
        Member.stub!(:authenticate).and_return(@user)
      end
      
      it "should log in the user" do
        post_create
        session[:user].should == @user.id
      end
      
      it "should redirect" do
        post_create
        response.should redirect_to('/')
      end
    end
    
    describe "with bad credentials" do
      before(:each) do
        Member.stub!(:authenticate).and_return(nil)
      end
      
      it "should not log in the user" do
        post_create
        session[:user].should be_nil
      end
      
      it "should redisplay the login form" do
        post_create
        response.should render_template('member_sessions/new')
      end
      
      def post_create
        post :create, :email => 'chris@example.com', :password => 'badpassword'
      end
    end
    
    def post_create
      post :create, :email => 'chris@example.com', :password => 'goodpassword'
    end
  end
end
