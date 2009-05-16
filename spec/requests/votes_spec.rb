require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a vote exists" do
  Vote.all.destroy!
  request(resource(:votes), :method => "POST", 
    :params => { :vote => { :id => nil, :for=>'Support'}})
end

describe "everything" do
  before { login }
  
describe "vote casting" do
  it "should cast a 'for' vote" do
    pending
  end
  
  it "should cast an 'against' vote" do
    pending
  end
end
end