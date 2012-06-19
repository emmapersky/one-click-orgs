require 'spec_helper'

describe "miscellaneous requests" do
  describe "internally-generated 404" do
    before(:each) do
      login
      get '/proposals/9999999'
    end
    
    it "should render the public/404.html file" do
      response.body.should =~ /The page you were looking for/
    end
    
    it "should not render using the application layout" do
      response.should_not have_selector "div.control_bar"
    end
  end
end
