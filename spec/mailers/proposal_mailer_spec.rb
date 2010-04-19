require 'spec_helper'

describe ProposalMailer do
  describe "notify_creation" do

    before do
      stub_constitution!
      stub_organisation!
      @member = Member.make
      @proposal = Proposal.make(:proposer_member_id=>@member.id)
    end
    
    it "should include welcome phrase and proposal information in email text" do
      mail = ProposalMailer.notify_creation(@member, @proposal)
      mail.body.should =~ /Dear #{@member.name}/
      mail.body.should =~ /#{@proposal.title}/
      mail.body.should =~ /#{@proposal.description}/            
    end
  
    it "should include correct propsal link in email text" do
      mail = ProposalMailer.notify_creation(@member, @proposal)
      mail.body.should =~ %r{http://test.com/proposals/\d+}
    end
  end
end