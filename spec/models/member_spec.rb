require 'spec_helper'
require 'lib/vote_error'

describe Member do

  before(:each) do
    Delayed::Job.delete_all 
    
    stub_constitution!
    stub_organisation!

    @member = @organisation.members.make
    @proposal = @organisation.proposals.make(:proposer_member_id => @member.id)
  end


  describe "defaults" do
    it "should be active" do
      @member.should be_active
    end
  end

  it "should not allow votes on members inducted after proposal was made" do
    new_member = @organisation.members.make(:created_at => Time.now + 1.day, :inducted_at => Time.now + 1.day)
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
    it "should send a welcome email" do
      MembersMailer.should_receive(:welcome_new_member).and_return(mock('mail', :deliver => nil))
      @organisation.members.create_member({:email=>'foo@example.com', :member_class=>MemberClass.make}, true)
    end
  end

  describe "ejection" do
    it "should toggle active flag after ejection" do
      lambda { @member.eject! }.should change(@member, :active?).from(true).to(false)
    end
  end


  describe "finders" do
    it "should return only active members" do
      @organisation.members.active.should == @organisation.members.all
      disabled = @organisation.members.make(:active=>false)
      @organisation.members.active.should == @organisation.members.all - [disabled]
    end
  end
  
  describe "name" do
    it "returns the full name for a member with first name and last name" do
      Member.new(:first_name => "Bob", :last_name => "Smith").name.should == "Bob Smith"
    end
    
    it "returns the first name for a member with a first name only" do
      Member.new(:first_name => "Bob").name.should == "Bob"
    end
    
    it "returns the last name for a member with a last name only" do
      Member.new(:last_name => "Smith").name.should == "Smith"
    end
    
    it "returns nil for a member with no first name and no last name" do
      Member.new.name.should be_nil
    end
  end
end
