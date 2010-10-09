require 'spec_helper'

describe "ResetPassword" do
  before(:each) do
    stub_constitution!
    stub_organisation!
  end
  
  describe "resetting a password" do
    before(:each) do
      @member = @organisation.members.make
      @organisation.stub!(:members).and_return(@members_relation = mock('members_relation', :where => [@member]))
      @member.stub!(:new_password!).and_return("letmein")
      @member.stub!(:save).and_return(true)
    end
    
    it "should generate a new password for the member" do
      @member.should_receive(:new_password!).and_return("letmein")
      post_reset
    end
  
    it "should display the done page" do
      post_reset
      @response.should render_template('reset_password/done')
    end
    
    def post_reset
      post('/reset_password/reset', {:email => @member.email})
    end
  end
end
