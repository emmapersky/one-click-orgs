require 'spec_helper'

describe "PasswordResets" do
  before(:each) do
    stub_constitution!
    stub_organisation!
  end
  
  describe "resetting a password" do
    before(:each) do
      @member = @organisation.members.make
      @organisation.stub!(:members).and_return(@members_relation = mock('members_relation', :where => [@member]))
    end
    
    it "should generate a new password reset code for the member" do
      @member.should_receive(:new_password_reset_code!)
      @member.stub!(:password_reset_code).and_return('abcdefghij')
      post_create
    end
  
    it "should display the confirmation page" do
      post_create
      @response.should render_template('password_resets/')
    end
    
    def post_create
      post('/password_resets', {:email => @member.email})
    end
  end
end
