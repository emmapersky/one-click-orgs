class VotesController < Application

  #FIXME duplication  
  def vote_for
    id, return_to = params[:id], params[:return_to]
    raise ArgumentError, "need proposal id" unless id
        
    begin
      current_user.cast_vote(:for, id)
      redirect_to return_to, :notice => "Vote for proposal cast"
    rescue Exception => e
      redirect_to return_to, :notice => "Error casting vote:#{e}"
    end
  end
  
  #FIXME duplication
  def vote_against
    id, return_to = params[:id], params[:return_to]
    raise ArgumentError, "need proposal id" unless id    
        
    begin
      current_user.cast_vote(:against, id)
      redirect_to return_to, :notice => "Vote against proposal cast"
    rescue
      redirect_to return_to, :notice => "Error casting vote"
    end    
  end
end 
