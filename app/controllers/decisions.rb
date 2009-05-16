class Decisions < Application
  # provides :xml, :yaml, :js
  
  def show(id)
    @decision = Decision.get(id)
    raise NotFound unless @decision
    
    vote = current_user.votes.first(:decision_id => @decision.id)
    if vote
      @decision.completed = true
      @decision.for = vote.for
    end
    
    display @decision
  end

  def create_proposal(decision)
    @proposal = Decision.new(decision)
    @proposal.proposer_member_id = current_user.id
    if @proposal.save
      redirect url('proposals'), :message => {:notice => "Proposal was successfully created"}
    else
      redirect url('proposals'), :message => {:notice => "Proposal not created"}      
    end
  end
end # Decisions
