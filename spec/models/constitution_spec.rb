require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Constitution do

  before do
    #avoid using th db in specs?
    Clause.create!(:name=>'general_voting_system', :text_value=>'RelativeMajority')        
    Clause.create!(:name=>'voting_period', :integer_value=>1000)
    Clause.create!(:name=>'organisation_name', :text_value=>'Test')
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
    
    it "should raise ArgumentError when invalid system is specified" do
      lambda { Constitution.change_voting_system(:general, nil) }.should raise_error(ArgumentError)              
      lambda { Constitution.change_voting_system(:general, 'Invalid') }.should raise_error(ArgumentError)        
    end    
  end
  
  describe "voting period" do
    it "should get the current voting period" do
      Constitution.voting_period.should be_an(Integer)
      Constitution.voting_period.should >(0)
      Constitution.voting_period.should ==(1000)            
    end
  end
  
  describe "organisation name" do
    it "should get the name of the organisation" do
      Constitution.organisation_name.should ==("Test")
    end
  end
end