require 'spec_helper'

describe Constitution do
  describe 'voting systems' do
    before do
      #avoid using the db in specs?
      Clause.set_text('general_voting_system', 'RelativeMajority')        
    end
  
    describe "getting voting systems" do
      it "should get the voting system" do
        Constitution.voting_system(:general).should ==(VotingSystems::RelativeMajority)
      end
    
      it "should raise ArgumentError if invalid voting system is specified" do
        lambda { Constitution.voting_system(:invalid) }.should raise_error(ArgumentError)
      end
    end
  
    describe "changing the voting system" do
      it "should change the voting system" do
        Constitution.change_voting_system(:general, 'Unanimous')
        Constitution.voting_system(:general).should ==(VotingSystems::Unanimous)
      end
      
      it "should keep track of the previous voting system after changing it"
    
      it "should raise ArgumentError when invalid system is specified" do
        lambda { Constitution.change_voting_system(:general, nil) }.should raise_error(ArgumentError)              
        lambda { Constitution.change_voting_system(:general, 'Invalid') }.should raise_error(ArgumentError)        
      end    
    end
  end
  
  describe "voting period" do
    before(:each) do
      Clause.set_integer('voting_period', 1000)
    end
    
    it "should get the current voting period" do
      Constitution.voting_period.should be_an(Integer)
      Constitution.voting_period.should >(0)
      Constitution.voting_period.should ==(1000)            
    end
    
    it "should change the current voting period" do
      lambda { Constitution.change_voting_period(86400 * 2) }.should change(Constitution, :voting_period).from(1000).to(86400*2)
    end
  end
end
