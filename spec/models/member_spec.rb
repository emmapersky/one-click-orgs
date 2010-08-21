require 'spec_helper'

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
    it "should schedule a welcome email delivery after member has been created" do
      lambda do
        @organisation.members.create_member({:email=>'foo@example.com', :member_class=>MemberClass.make}, true)
      end.should change { Delayed::Job.count }.by(1)
      
      job = Delayed::Job.first
      job.payload_object.class.should   == Delayed::PerformableMethod
      job.payload_object.method.should  == :send_email_without_send_later
      job.payload_object.args.should    == []
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

end
