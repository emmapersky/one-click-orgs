class VotesController < ApplicationController

  before_filter :require_vote_permission, :only => [:vote_for, :vote_against]

  #FIXME duplication  
  def vote_for
    id, return_to = params[:id], params[:return_to]
    raise ArgumentError, "need proposal id" unless id
        
    begin
      current_user.cast_vote(:for, id)
      redirect_to return_to, :notice => "Vote for proposal cast"
    rescue Exception => e
      redirect_to return_to, :notice => "Error casting vote: #{e}"
    end
  end
  
  #FIXME duplication
  def vote_against
    id, return_to = params[:id], params[:return_to]
    raise ArgumentError, "need proposal id" unless id    
        
    begin
      current_user.cast_vote(:against, id)
      redirect_to return_to, :notice => "Vote against proposal cast"
    rescue Exception => e
      redirect_to return_to, :notice => "Error casting vote: #{e}"
    end    
  end

private

  def require_vote_permission
    if !current_user.has_permission(:vote)
      flash[:error] = "You do not have sufficient permissions to vote!"
      redirect_back_or_default
    end
  end
end 
