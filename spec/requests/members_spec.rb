require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a member exists" do
  @member = Member.make
end

describe "everything" do
  before(:each) do 
    stub_constitution!
    stub_organisation!
    login
  end
  
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
      it "should create the proposal to eject the member" do
        
        EjectMemberProposal.should_receive(:serialize_parameters).with('id' => @member.id).and_return(@serialized_parameters = mock('serialized parameters'))
        EjectMemberProposal.should_receive(:new).with(
          :parameters => @serialized_parameters,
          :title => "Eject #{@member.name} from test",
          :proposer_member_id => @user.id
        ).and_return(@proposal = mock('proposal'))
        @proposal.should_receive(:save).and_return(true)
        
        make_request
      end

      it "should redirect to the control center" do
        make_request
        @response.should redirect_to('/one_click/control_centre')
      end
      
      def make_request
        @response = request(resource(@member), :method => "DELETE")
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

