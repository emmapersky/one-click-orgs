require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Merb::GlobalHelpers do
  include Merb::GlobalHelpers
  
  describe "url generation" do
    it "should return generate an absolute url" do
      absolute_oco_url('foo').should ==('http://test.com/foo')
    end
  end
  
  it "should return the domain" do
      oco_domain.should == 'http://test.com'
  end
  
  it "should pluralize properly" do
    pluralize(500, 'mile').should == '500 miles'
  end
  
  it "should display a nice readable text for remaining time" do
    time_to_go_in_words(Time.now, Time.now + 10, true).should == 'less than 20 seconds'
    time_to_go_in_words(Time.now, Time.now + 10).should == 'less than a minute'
    time_to_go_in_words(Time.now, Time.now + 30).should == '1 minute'
    time_to_go_in_words(Time.now, Time.now + 300).should == '5 minutes'
    time_to_go_in_words(Time.now, Time.now + 3000).should == 'about 1 hour'
    time_to_go_in_words(Time.now, Time.now + 30000).should == 'about 8 hours'
    time_to_go_in_words(Time.now, Time.now + 300000).should == '3 days'
    time_to_go_in_words(Time.now, Time.now + 3000000).should == 'about 1 month'
    time_to_go_in_words(Time.now, Time.now + 30000000).should == '11 months'
    time_to_go_in_words(Time.now, Time.now + 300000000).should == 'over 9 years'
  end
end