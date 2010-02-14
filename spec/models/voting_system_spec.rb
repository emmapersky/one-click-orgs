require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe VotingSystems do

  def make_proposal(v_for, v_against, total_m=v_for+v_against)
    p = mock(Proposal)
    p.stub!(:votes_for).and_return(v_for)
    p.stub!(:votes_against).and_return(v_against)
    p.stub!(:member_count).and_return(total_m)
    p
  end

  def _should_have_description
    @system.description.should_not be_blank
  end
  
  def should_pass(proposal)
     @system.passed?(proposal).should be_true
  end

  def should_not_pass(proposal)
     @system.passed?(proposal).should be_false
  end

  describe VotingSystems do
    it "should return all voting systems" do
      VotingSystems.all.map {|s|s.name.split('::')[-1] }.should == ["RelativeMajority", "AbsoluteMajority", "AbsoluteTwoThirdsMajority", "Unanimous", "Veto"]
    end
  end
  
  describe VotingSystems::RelativeMajority do    
    before do
      @system = VotingSystems::RelativeMajority
    end

    it "relative majority" do
      should_not_pass make_proposal(0, 0)
      should_pass make_proposal(5, 4)
      should_not_pass make_proposal(4, 5)
    end
  end

  describe VotingSystems::Veto do    
    before(:each) do
      @system = VotingSystems::Veto
    end

    it "should have a description" do
      _should_have_description
    end
    
    it "veto" do
      should_pass make_proposal(0, 0)
      should_not_pass make_proposal(5, 4)
      should_not_pass make_proposal(4, 5)
    end
  end

  describe VotingSystems::AbsoluteMajority do    
    before do
      @system = VotingSystems::AbsoluteMajority
    end

    it "absolute" do
      should_pass make_proposal(10, 9)
      should_not_pass make_proposal(9, 10)
    end
  end


  describe VotingSystems::AbsoluteTwoThirdsMajority do    
    before do
      @system = VotingSystems::AbsoluteTwoThirdsMajority
    end

    it "absolute two thirds majority" do
      should_pass make_proposal(67, 33)
      should_not_pass make_proposal(4, 5)
      should_not_pass make_proposal(51, 49)            
    end
  end


  describe VotingSystems::Unanimous do    
    before do
      @system = VotingSystems::Unanimous
    end
    
    it "unanimous" do
      should_not_pass make_proposal(0, 0)
      should_pass make_proposal(5, 0)
      should_not_pass make_proposal(10, 1)
    end
  end

end
