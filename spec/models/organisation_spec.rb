require 'spec_helper'

describe Organisation do
  before(:each) do
    @organisation = Organisation.make
  end
  
  describe "validation" do
    it "should not allow multiple organisations with the same subdomain" do
      @first = Organisation.make(:subdomain => "apples")

      lambda do
        @second = Organisation.make(:subdomain => "apples")
      end.should raise_error(ActiveRecord::RecordInvalid)
    end
  end
  
  describe "text fields" do
    before(:each) do
      @organisation.clauses.set_text('organisation_name', 'The Cheese Collective')
      @organisation.clauses.set_text('objectives', 'eat all the cheese')
      @organisation.clauses.set_text('domain', 'fromage.com')
    end
    
    it "should get the name of the organisation" do
      @organisation.organisation_name.should == ("The Cheese Collective")
    end

    it "should get the objectives of the organisation" do
      @organisation.objectives.should == ("eat all the cheese")
    end

    it "should get the domain" do
      @organisation.domain.should == ("fromage.com")
    end
    
    it "should change the name of the organisation" do
      lambda {
        @organisation.clauses.set_text(:organisation_name, "The Yoghurt Yurt")
      }.should change(Clause, :count).by(1)
      @organisation.organisation_name.should == "The Yoghurt Yurt"
    end
    
    it "should change the objectives of the organisation" do
      lambda {
        @organisation.clauses.set_text(:objectives, "make all the yoghurt")
      }.should change(Clause, :count).by(1)
      @organisation.objectives.should == "make all the yoghurt"
    end
    
    it "should change the domain of the organisation" do
      lambda {
        @organisation.clauses.set_text(:domain, "yaourt.org")
      }.should change(Clause, :count).by(1)
      @organisation.domain.should == "yaourt.org"
    end
  end
  
  describe "domain" do
    it "should return the domain clause" do
      @organisation.clauses.stub!(:get_text).with('domain').and_return("http://oneclickorgs.com")
      @organisation.domain.should == "http://oneclickorgs.com"
    end
    
    describe "only_host option" do
      it "should remove an http://" do
        @organisation.clauses.stub!(:get_text).with('domain').and_return("http://oneclickorgs.com/")
        @organisation.domain(:only_host => true).should == "oneclickorgs.com"
      end
    
      it "should remove an https://" do
        @organisation.clauses.stub!(:get_text).with('domain').and_return("https://oneclickorgs.com/")
        @organisation.domain(:only_host => true).should == "oneclickorgs.com"
      end
    
      it "should leave a naked domain alone" do
        @organisation.clauses.stub!(:get_text).with('domain').and_return("oneclickorgs.com")
        @organisation.domain(:only_host => true).should == "oneclickorgs.com"
      end
    end
  end
end
