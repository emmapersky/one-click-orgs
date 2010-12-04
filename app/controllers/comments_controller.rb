class CommentsController < ApplicationController
  before_filter :find_proposal
  
  def create
    @comment = @proposal.comments.build(params[:comment])
    @comment.author = current_user
    if @comment.save
      redirect_to(proposal_path(@proposal), :notice => "Comment added.")
    else
      redirect_to(proposal_path(@proposal), :error => "There was a problem saving your comment.")
    end
  end
  
protected
  
  def find_proposal
    @proposal = co.proposals.find(params[:proposal_id])
  end
end
