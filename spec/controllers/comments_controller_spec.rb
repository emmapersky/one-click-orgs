require 'spec_helper'

describe CommentsController do
  describe "POST create" do
    before(:each) do
      controller.stub(:ensure_set_up).and_return(true)
      controller.stub(:ensure_organisation_exists).and_return(true)
      controller.stub(:ensure_authenticated).and_return(true)
      controller.stub(:ensure_member_active).and_return(true)
      controller.stub(:ensure_organisation_active).and_return(true)
      controller.stub(:ensure_member_inducted).and_return(true)
      
      @organisation = mock_model(Organisation)
      controller.stub!(:co).and_return(@organisation)
      
      @proposals_association = mock("proposals association")
      @organisation.stub!(:proposals).and_return(@proposals_association)
      
      @proposal = mock_model(Proposal, :to_param => '1')
      @proposals_association.stub!(:find).and_return(@proposal)
      
      @comments_association = mock("comments association")
      @proposal.stub!(:comments).and_return(@comments_association)
      
      @comment = mock_model(Comment, :save => true, :author= => nil)
      @comments_association.stub!(:build).and_return(@comment)
      
      @comment_body = "This is my comment."
      
      @member = mock_model(Member)
      controller.stub!(:current_user).and_return(@member)
    end
    
    def post_create
      post :create, :proposal_id => 1, :comment => {'body' => @comment_body}
    end
    
    it "should build the comment" do
      @comments_association.should_receive(:build).and_return(@comment)
      post_create
    end
    
    it "should assign the author" do
      @comment.should_receive(:author=).with(@member)
      post_create
    end
    
    it "should assign the body" do
      @comments_association.should_receive(:build).with(hash_including('body' => @comment_body)).and_return(@comment)
      post_create
    end
    
    it "should save the comment" do
      @comment.should_receive(:save).and_return(true)
      post_create
    end
    
    it "should redirect to the proposal" do
      post_create
      response.should redirect_to('/proposals/1')
    end
  end
end
