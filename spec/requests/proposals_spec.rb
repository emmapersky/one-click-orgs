require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a proposal exists" do
  Proposal.all.destroy!  
  login    
  request(resource(:proposals), :method => "POST", 
    :params => { :proposal => 
        { :id => nil, :proposer_member_id => Member.first.id, :title=>'proposal' }
               }).should redirect_to(url('proposals'), :message => {:notice => "proposal was successfully created"})    
end

describe "everything" do
  before do 
    login
  end
describe "resource(:proposals)" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:proposals))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of proposals" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a proposal exists" do
    before(:each) do
      @response = request(resource(:proposals))
    end
    
    it "has a list of proposals" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
end

describe "resource(@proposal)" do 
  before { login }
  
  describe "a successful DELETE", :given => "a proposal exists" do
     before(:each) do
       @response = request(resource(Proposal.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:proposals))
     end

   end
end

describe "resource(:proposals, :new)" do
  before(:each) do
    @response = request(resource(:proposals, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@proposal, :edit)", :given => "a proposal exists" do
  before(:each) do
    @response = request(resource(Proposal.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@proposal)", :given => "a proposal exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Proposal.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @proposal = Proposal.first
      @response = request(resource(@proposal), :method => "PUT", 
        :params => { :proposal => {:id => @proposal.id, :title=>'foo'} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@proposal))
    end
  end
end
end

