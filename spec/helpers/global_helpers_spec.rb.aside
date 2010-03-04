require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Merb::GlobalHelpers do
  include Merb::GlobalHelpers
  
  before do
    stub_constitution!
    stub_organisation!
  end
  
  describe "url generation" do
    it "should return generate an absolute url" do
      absolute_oco_url('foo').should ==('http://test.com/foo')
    end
    
    it "should return generate an absolute url for a resource" do
      absolute_oco_resource(Proposal.new(:id=>1)).should ==('http://test.com/proposals/1')
    end
  end
  
  it "should return the domain" do
      oco_domain.should == 'http://test.com'
  end
  
  
  it "should pluralize properly" do
    pluralize(500, 'mile').should == '500 miles'
  end
  
  it "should display a nice readable text for remaining time" do
    distance_of_time_in_words(Time.now, Time.now + 10, true).should == 'less than 20 seconds'
    distance_of_time_in_words(Time.now, Time.now + 10).should == 'less than a minute'
    distance_of_time_in_words(Time.now, Time.now + 30).should == '1 minute'
    distance_of_time_in_words(Time.now, Time.now + 300).should == '5 minutes'
    distance_of_time_in_words(Time.now, Time.now + 3000).should == 'about 1 hour'
    distance_of_time_in_words(Time.now, Time.now + 30000).should == 'about 8 hours'
    distance_of_time_in_words(Time.now, Time.now + 300000).should == '3 days'
    distance_of_time_in_words(Time.now, Time.now + 3000000).should == 'about 1 month'
    distance_of_time_in_words(Time.now, Time.now + 30000000).should == '11 months'
    distance_of_time_in_words(Time.now, Time.now + 300000000).should == 'over 9 years'
  end
end