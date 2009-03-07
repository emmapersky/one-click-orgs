require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a decision exists" do
  Decision.all.destroy!  
  login    
  request(resource(:decisions), :method => "POST", 
    :params => { :decision => 
        { :id => nil, :proposer_member_id => Member.first.id, :title=>'proposal' }
               }).should redirect_to(url('decisions'), :message => {:notice => "decision was successfully created"})    
end

describe "everything" do
  before do 
    login
  end
describe "resource(:decisions)" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:decisions))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of decisions" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a decision exists" do
    before(:each) do
      @response = request(resource(:decisions))
    end
    
    it "has a list of decisions" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
end

describe "resource(@decision)" do 
  before { login }
  
  describe "a successful DELETE", :given => "a decision exists" do
     before(:each) do
       @response = request(resource(Decision.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:decisions))
     end

   end
end

describe "resource(:decisions, :new)" do
  before(:each) do
    @response = request(resource(:decisions, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@decision, :edit)", :given => "a decision exists" do
  before(:each) do
    @response = request(resource(Decision.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@decision)", :given => "a decision exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Decision.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @decision = Decision.first
      @response = request(resource(@decision), :method => "PUT", 
        :params => { :decision => {:id => @decision.id, :title=>'foo'} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@decision))
    end
  end
end
end

