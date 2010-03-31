require 'spec_helper'

describe Organisation do
  
  describe "text fields" do
    before(:each) do
      Clause.set_text('organisation_name', 'The Cheese Collective')
      Clause.set_text('objectives', 'eat all the cheese')
      Clause.set_text('domain', 'fromage.com')
    end
    
    it "should get the name of the organisation" do
      Organisation.organisation_name.should == ("The Cheese Collective")
    end

    it "should get the objectives of the organisation" do
      Organisation.objectives.should == ("eat all the cheese")
    end

    it "should get the domain" do
      Organisation.domain.should == ("fromage.com")
    end
    
    it "should change the name of the organisation" do
      lambda {
        Clause.set_text(:organisation_name, "The Yoghurt Yurt")
      }.should change(Clause, :count).by(1)
      Organisation.organisation_name.should == "The Yoghurt Yurt"
    end
    
    it "should change the objectives of the organisation" do
      lambda {
        Clause.set_text(:objectives, "make all the yoghurt")
      }.should change(Clause, :count).by(1)
      Organisation.objectives.should == "make all the yoghurt"
    end
    
    it "should change the domain of the organisation" do
      lambda {
        Clause.set_text(:domain, "yaourt.org")
      }.should change(Clause, :count).by(1)
      Organisation.domain.should == "yaourt.org"
    end
  end
  
  describe "domain" do
    it "should return the domain clause" do
      Clause.stub!(:get_text).with('domain').and_return("http://oneclickorgs.com")
      Organisation.domain.should == "http://oneclickorgs.com"
    end
    
    describe "only_host option" do
      it "should remove an http://" do
        Clause.stub!(:get_text).with('domain').and_return("http://oneclickorgs.com/")
        Organisation.domain(:only_host => true).should == "oneclickorgs.com"
      end
    
      it "should remove an https://" do
        Clause.stub!(:get_text).with('domain').and_return("https://oneclickorgs.com/")
        Organisation.domain(:only_host => true).should == "oneclickorgs.com"
      end
    
      it "should leave a naked domain alone" do
        Clause.stub!(:get_text).with('domain').and_return("oneclickorgs.com")
        Organisation.domain(:only_host => true).should == "oneclickorgs.com"
      end
    end
  end
end
