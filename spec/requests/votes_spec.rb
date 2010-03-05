require 'spec_helper'

describe "everything" do
  before do 
    @user = login 
  end
      
  describe "vote casting" do
    it "should cast a 'for' vote" do
      #FIXME
      #@user.should_receive(:cast_vote).with(:for, 1)
      
      post('/votes/vote_for/1', {:return_to => '/foo'})
      response.should redirect_to('/foo')
    end
  
    it "should cast an 'against' vote" do
      #FIXME
      #@user.should_receive(:cast_vote).with(:against, 1)
      
      post(url_for(:controller => 'votes', :action => 'vote_against', :id => 1), {:return_to => '/foo'})
      response.should redirect_to '/foo'
    end
  end
end