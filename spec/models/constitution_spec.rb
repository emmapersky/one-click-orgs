require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Constitution do
  describe 'voting systems' do
    before do
      #avoid using the db in specs?
      Clause.create!(:name=>'general_voting_system', :text_value=>'RelativeMajority')        
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
      
      it "should keep track of the previous voting system after changing it" do
        pending
      end
    
      it "should raise ArgumentError when invalid system is specified" do
        lambda { Constitution.change_voting_system(:general, nil) }.should raise_error(ArgumentError)              
        lambda { Constitution.change_voting_system(:general, 'Invalid') }.should raise_error(ArgumentError)        
      end    
    end
  end
  
  describe "voting period" do
    before(:each) do
      Clause.create!(:name=>'voting_period', :integer_value=>1000)
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
  
  describe "text fields" do
    before(:each) do
      Clause.create!(:name=>'organisation_name', :text_value=>'The Cheese Collective')
      Clause.create!(:name => 'objectives', :text_value => 'eat all the cheese')
      Clause.create!(:name => 'domain', :text_value => 'fromage.com')
    end
    
    it "should get the name of the organisation" do
      Constitution.organisation_name.should == ("The Cheese Collective")
    end

    it "should get the objectives of the organisation" do
      Constitution.objectives.should == ("eat all the cheese")
    end

    it "should get the domain" do
      Constitution.domain.should == ("fromage.com")
    end
    
    it "should change the name of the organisation" do
      lambda {
        Constitution.set_text(:organisation_name, "The Yoghurt Yurt")
      }.should change(Clause, :count).by(1)
      Constitution.organisation_name.should == "The Yoghurt Yurt"
    end
    
    it "should change the objectives of the organisation" do
      lambda {
        Constitution.set_text(:objectives, "make all the yoghurt")
      }.should change(Clause, :count).by(1)
      Constitution.objectives.should == "make all the yoghurt"
    end
    
    it "should change the domain of the organisation" do
      lambda {
        Constitution.set_text(:domain, "yaourt.org")
      }.should change(Clause, :count).by(1)
      Constitution.domain.should == "yaourt.org"
    end
  end
end