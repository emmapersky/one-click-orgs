require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/one_click" do
  before(:each) do
    @response = request("/one_click")
  end
end