require 'spec_helper'

describe Setting do
  before(:each) do
    Setting.make(:key => "base_domain", :value => "oneclickorgs.com")
  end
  
  describe "when getting" do
    it "should return the value for an existing key" do
      Setting[:base_domain].should == "oneclickorgs.com"
    end
    
    it "should return nil for a non-existent key" do
      Setting[:kwyjibo].should be_nil
    end
  end
  
  describe "when setting" do
    it "should create a new setting for a new key" do
      lambda{Setting[:new_key] = "new_value"}.should change(Setting, :count).by(1)
      Setting[:new_key].should == "new_value"
    end
    
    it "should update an existing setting for an existing key" do
      lambda{Setting[:base_domain] = "google.com"}.should_not change(Setting, :count)
      Setting[:base_domain].should == "google.com"
    end
  end
end
