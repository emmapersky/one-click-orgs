require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a member exists" do
  @member = Member.make
end

describe "ResetPassword" do
  before(:each) do
    stub_constitution!
    stub_organisation!
  end
  
  describe "resetting a password", :given => "a member exists" do
    before(:each) do
      Member.stub!(:first).and_return(@member)
      @member.stub!(:new_password!).and_return("letmein")
      @member.stub!(:save).and_return(true)
    end
    
    it "should generate a new password for the member" do
      @member.should_receive(:new_password!).and_return("letmein")
      post_reset
    end
  
    it "should redirect to the index page" do
      post_reset
      @response.should redirect_to(url(:controller => 'reset_password', :action => 'index'))
    end
    
    def post_reset
      @response = request('/reset_password/reset', :method => "POST", :params => {:email => @member.email})
    end
  end
end
