require 'spec_helper'

describe Organisation do
  before(:each) do
    @organisation = Organisation.make(:subdomain => 'fromage')
    Setting[:base_domain] = 'oneclickorgs.com'
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
    end
    
    it "should get the name of the organisation" do
      @organisation.organisation_name.should == ("The Cheese Collective")
    end

    it "should get the objectives of the organisation" do
      @organisation.objectives.should == ("eat all the cheese")
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
  end
  
  describe "domain" do
    it "should return the root URL for this organisation" do
      @organisation.domain.should == "http://fromage.oneclickorgs.com"
    end
    
    context "with only_host option true" do
      it "should remove the http://" do
        @organisation.domain(:only_host => true).should == "fromage.oneclickorgs.com"
      end
    end
  end
end
