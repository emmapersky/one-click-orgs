require 'spec_helper'

describe "proposal_mailer/notify_creation.text.erb" do
  before(:each) do
    @member = Member.make
    assigns[:member] = @member
    
    @proposal = mock_model(Proposal, :title => "Buy more yaks", :description => "We're running low & they're cheap.", :to_param => '1', :proposer => mock_model(Member, :name => "Emma Baker"))
    assigns[:proposal] = @proposal
  end
  
  it "should not HTML-escape the proposal details" do
    render
    rendered.should contain "We're running low & they're cheap."
  end
end
