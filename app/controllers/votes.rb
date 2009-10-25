class Votes < Application
  # provides :xml, :yaml, :js
  
  def vote_for    
    id, return_to = params[:id], params[:return_to]
    
    begin
      current_user.cast_vote(:for, id)
      redirect return_to, :message => {:notice => "Vote for proposal cast"}
    rescue Exception => e
      redirect return_to, :message => {:notice => "Error casting vote:#{e}"}      
    end
  end
  
  def vote_against
    id, return_to = params[:id], params[:return_to]
        
    begin
      current_user.cast_vote(:against, id)
      redirect return_to, :message => {:notice => "Vote against proposal cast"}
    rescue
      redirect return_to, :message => {:notice => "Error casting vote"}      
    end    
  end
end 

# Votes
