require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a decision exists" do
  Decision.all.destroy!  
  login    
  request('/proposals/create', :method => "POST", 
    :params => { :decision => 
        { :id => nil, :proposer_member_id => Member.first.id, :title=>'proposal' }
               })
end

describe "everything" do
  before do 
    login
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
end
end

