require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a vote exists" do
end

describe "everything" do
  before do 
    @user = login 
  end
      
  describe "vote casting" do
    it "should cast a 'for' vote" do
      #FIXME
      #@user.should_receive(:cast_vote).with(:for, 1)
      
      request(url(
      :controller=>'votes', 
        :action=>'vote_for',
        :id=>1),
        :method=>'POST', :params=>{:return_to=>'/foo'}).should redirect_to("/foo")
        

    end
  
    it "should cast an 'against' vote" do
      #FIXME
      #@user.should_receive(:cast_vote).with(:against, 1)
            
      request(url(
        :controller=>'votes', 
        :action=>'vote_against',
        :id => 1),
        :method=>'POST', :params=>{:return_to=>'/foo'}).should redirect_to("/foo")        
    end
  end
end