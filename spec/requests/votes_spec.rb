require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a vote exists" do
  Vote.all.destroy!
  request(resource(:votes), :method => "POST", 
    :params => { :vote => { :id => nil }})
end

describe "resource(:votes)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:votes))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of votes" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a vote exists" do
    before(:each) do
      @response = request(resource(:votes))
    end
    
    it "has a list of votes" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Vote.all.destroy!
      @response = request(resource(:votes), :method => "POST", 
        :params => { :vote => { :id => nil }})
    end
    
    it "redirects to resource(:votes)" do
      @response.should redirect_to(resource(Vote.first), :message => {:notice => "vote was successfully created"})
    end
    
  end
end

describe "resource(@vote)" do 
  describe "a successful DELETE", :given => "a vote exists" do
     before(:each) do
       @response = request(resource(Vote.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:votes))
     end

   end
end

describe "resource(:votes, :new)" do
  before(:each) do
    @response = request(resource(:votes, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@vote, :edit)", :given => "a vote exists" do
  before(:each) do
    @response = request(resource(Vote.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@vote)", :given => "a vote exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Vote.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @vote = Vote.first
      @response = request(resource(@vote), :method => "PUT", 
        :params => { :vote => {:id => @vote.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@vote))
    end
  end
  
end

