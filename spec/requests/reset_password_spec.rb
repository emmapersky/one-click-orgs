require 'spec_helper'

describe "ResetPassword" do
  before(:each) do
    stub_constitution!
    stub_organisation!
  end
  
  describe "resetting a password" do
    before(:each) do
      @member = Member.make
      Member.stub!(:where).with(:email => @member.email).and_return(@members_relation = mock('members relation'))
      @members_relation.stub!(:first).and_return(@member)
      @member.stub!(:new_password!).and_return("letmein")
      @member.stub!(:save).and_return(true)
    end
    
    it "should generate a new password for the member" do
      @member.should_receive(:new_password!).and_return("letmein")
      post_reset
    end
  
    it "should redirect to the index page" do
      post_reset
      @response.should redirect_to(:controller => 'reset_password', :action => 'index')
    end
    
    def post_reset
      post('/reset_password/reset', {:email => @member.email})
    end
  end
end
