require 'spec_helper'

describe "induction process" do
  before(:each) do
    stub_setup!
    Organisation.stub!(:find_by_host).and_return(@organisation = Organisation.make(:name => 'myorg', :objectives => 'myobj'))
  end

  # TODO implement tests once new induction has been implemented  

end
