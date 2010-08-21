require 'spec_helper'

describe DecisionMailer do
  before :each do
    stub_constitution!
    stub_organisation!
    @member = @organisation.members.make
    @proposal = @organisation.proposals.make(:proposer_member_id=>@member.id)
    @decision = Decision.make(:proposal=>@proposal)
  end
  
  describe "notify_new_decision" do
    it "should include welcome phrase and proposal information in email text" do
      mail = DecisionMailer.notify_new_decision(@member, @decision)
      mail.body.should =~ /Dear #{@member.name}/
      mail.body.should =~ /a new decision has been made/
      mail.body.should =~ /#{@proposal.title}/
      mail.body.should =~ /#{@proposal.description}/           
    end

    it "should include correct decision link in email text" do
      mail = DecisionMailer.notify_new_decision(@member, @decision)
      mail.body.should =~ %r{http://test.oneclickorgs.com/decisions/\d+}
    end
  end
end
