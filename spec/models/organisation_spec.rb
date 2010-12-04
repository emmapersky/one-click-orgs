require 'spec_helper'

describe Organisation do
  before(:each) do
    @organisation = Organisation.make(:name => 'abc', :objectives => 'To boldly go', :subdomain => 'fromage')
    Setting[:base_domain] = 'oneclickorgs.com'
  end
  
  describe "validation" do
    it "should not allow multiple organisations with the same subdomain" do
      @first = Organisation.make(:name => 'abc', :objectives => 'To boldly go', :subdomain => "apples")

      lambda do
        @second = Organisation.make(:name => 'def', :objectives => 'To boldly go', :subdomain => "apples")
      end.should raise_error(ActiveRecord::RecordInvalid)
    end
  end
  
  describe "text fields" do
    before(:each) do
      @organisation.name = 'The Cheese Collective' # actually stored as 'organisation_name'
      @organisation.objectives = 'eat all the cheese' # actually stored as 'organisation_objectoves'
      @organisation.save!
      @organisation.reload
    end
    
    it "should get the name of the organisation" do
      @organisation.name.should == ("The Cheese Collective")
    end

    it "should get the objectives of the organisation" do
      @organisation.objectives.should == ("eat all the cheese")
    end
    
    it "should change the name of the organisation" do
      lambda {
        @organisation.name = "The Yoghurt Yurt"
        @organisation.save!
        @organisation.reload
      }.should change(Clause, :count).by(1)
      @organisation.name.should == "The Yoghurt Yurt"
    end
    
    it "should change the objectives of the organisation" do
      lambda {
        @organisation.objectives = "make all the yoghurt"
        @organisation.save!
        @organisation.reload
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
