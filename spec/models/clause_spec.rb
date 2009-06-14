require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Clause do
  before(:each) do
    @old_objectives = Clause.make(:name => 'objectives', :started_at => (Time.now - 3.days), :ended_at => (Time.now - 1.day), :text_value => "consuming ice-cream")
    @current_objectives = Clause.make(:name => 'objectives', :started_at => (Time.now - 1.day), :text_value => "consuming doughnuts")
    @current_voting_period = Clause.make(:name => 'voting_period', :started_at => (Time.now - 1.day), :integer_value => 1)
  end
  
  it "should find the current objectives" do
    Clause.get_current('objectives').should == @current_objectives
  end
end
