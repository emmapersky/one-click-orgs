require 'spec_helper'

describe Member do

  before(:each) do
    stub_constitution!
    stub_organisation!

    @member = Member.make
    @proposal = Proposal.make(:proposer_member_id => @member.id)
  end


  describe "defaults" do
    it "should be active" do
      @member.should be_active
    end
  end

  it "should not allow votes on members created before proposals" do
    new_member = Member.make(:created_at => Time.now + 1.day)
    lambda {
      new_member.cast_vote(:for, @proposal.id)
    }.should raise_error(VoteError)
  end

  it "should not allow additional votes" do
    @member.cast_vote(:for, @proposal.id)

    lambda {
      @member.cast_vote(:against, @proposal.id)
    }.should raise_error(VoteError)
  end

  describe "passwords" do
    it "should generate a new random password" do
      new_pass = @member.new_password!(10)
      new_pass.size.should == 10
    end

    it "should have at least 6 characters" do
      lambda { @member.new_password!(1) }.should raise_error(ArgumentError)
    end
  end

  describe "creation" do
    it "should send out an email after membes has been created" do
      mailer = mock("mailer")
      mailer.stub!(:deliver)
      MembersMailer.should_receive(:welcome_new_member).and_return(mailer)
      Member.create_member({:email=> 'foo@example.com'}, true)
    end
  end

  describe "ejection" do
    it "should toggle active flag after ejection" do
      lambda { @member.eject! }.should change(@member, :active?).from(true).to(false)
    end
  end


  describe "finders" do
    it "should return only active members" do
      Member.active.should == Member.all
      disabled = Member.make(:active=>false)
      Member.active.should == Member.all - [disabled]
    end
  end

end