require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a member exists" do
  @member = Member.make
end

describe "everything" do
  before { login }
describe "resource(:members)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:members))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of members" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a member exists" do
    before(:each) do
      @response = request(resource(:members))
    end
    
    it "has a list of members" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      @response = request(resource(:members), :method => "POST", 
        :params => { :member => { :id => nil, :email=>'anemail@example.com', :name=>"test" }})
    end
    
    it "redirects to resource(:members)" do
      @response.should redirect_to(resource(:members), :message => {:notice => "member was successfully created"})
    end    
  end
end

describe "resource(@member)" do 
  describe "a successful DELETE", :given => "a member exists" do
     before(:each) do
       @response = request(resource(@member), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:members))
     end

   end
end

describe "resource(@member, :edit)", :given => "a member exists" do
  before(:each) do
  end
  
  it "responds successfully if resource == current_user" do
    @response = request(resource(default_user, :edit))  
    @response.should be_successful
  end

  it "responds unauthorized if resource != current_user" do
    @response = request(resource(@member, :edit))  
    @response.status.should == 401
  end  
end



describe "resource(@member)", :given => "a member exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(default_user))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @response = request(resource(@member), :method => "PUT", 
        :params => { :member => {:id => @member.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@member))
    end
  end
end
end

