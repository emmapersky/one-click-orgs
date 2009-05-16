class Proposals < Application
  # provides :xml, :yaml, :js
  
  def show(id)
    @proposal = Proposal.get(id)
    raise NotFound unless @proposal
    
    vote = current_user.votes.first(:proposal_id => @proposal.id)
    if vote
      @proposal.completed = true
      @proposal.for = vote.for
    end
    
    display @proposal
  end

  def create(proposal)
    @proposal = Proposal.new(proposal)
    @proposal.proposer_member_id = current_user.id #fixme
        
    if @proposal.save
      redirect resource(@proposal), :message => {:notice => "Proposal was successfully created"}
    else
      redirect '/', :message => {:error => "Proposal not created"}
    end
  end
  

end # Proposals
