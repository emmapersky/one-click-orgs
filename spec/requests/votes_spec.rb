require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a vote exists" do
  Vote.all.destroy!
  request(resource(:votes), :method => "POST", 
    :params => { :vote => { :id => nil, :for=>'Support'}})
end

describe "everything" do
  before do 
    login 
  end
      
  describe "vote casting" do
    it "should cast a 'for' vote" do
      raise "implement me"
    end
  
    it "should cast an 'against' vote" do
      raise "implement me"
    end
  end
end