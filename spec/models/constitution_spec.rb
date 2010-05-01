require 'spec_helper'

describe Constitution do
  before(:each) do
    @organisation = Organisation.make
  end
  
  describe 'voting systems' do
    before do
      #avoid using the db in specs?
      @organisation.clauses.set_text('general_voting_system', 'RelativeMajority')        
    end
  
    describe "getting voting systems" do
      it "should get the voting system" do
        @organisation.constitution.voting_system(:general).should ==(VotingSystems::RelativeMajority)
      end
    
      it "should raise ArgumentError if invalid voting system is specified" do
        lambda { @organisation.constitution.voting_system(:invalid) }.should raise_error(ArgumentError)
      end
    end
  
    describe "changing the voting system" do
      it "should change the voting system" do
        @organisation.constitution.change_voting_system(:general, 'Unanimous')
        @organisation.constitution.voting_system(:general).should ==(VotingSystems::Unanimous)
      end
      
      it "should keep track of the previous voting system after changing it"
    
      it "should raise ArgumentError when invalid system is specified" do
        lambda { @organisation.constitution.change_voting_system(:general, nil) }.should raise_error(ArgumentError)              
        lambda { @organisation.constitution.change_voting_system(:general, 'Invalid') }.should raise_error(ArgumentError)        
      end    
    end
  end
  
  describe "voting period" do
    before(:each) do
      @organisation.clauses.set_integer('voting_period', 1000)
    end
    
    it "should get the current voting period" do
      @organisation.constitution.voting_period.should be_an(Integer)
      @organisation.constitution.voting_period.should >(0)
      @organisation.constitution.voting_period.should ==(1000)            
    end
    
    it "should change the current voting period" do
      lambda { @organisation.constitution.change_voting_period(86400 * 2) }.should change(@organisation.constitution, :voting_period).from(1000).to(86400*2)
    end
  end
end
