class Decisions < Application
  # provides :xml, :yaml, :js
  
  def index
    @decisions = Decision.all(:close_date.lt => Time.now, :order => [:close_date.desc]).select{|v| v.accepted}
    display @decisions
  end

  def proposals
    @proposals = Decision.all(:open => true, :close_date.gt => Time.now)
    
    completed_votes = current_user.votes
    completed_decisions = {}
    completed_votes.each{|v| completed_decisions[v.decision_id] = v.for}
    
    @proposals.each do |p| 
      p.completed = completed_decisions.keys.include? p.id
      p.for = completed_decisions[p.id]
    end
    
    @new_proposal = Decision.new
    display @proposals
    display @new_proposal
  end

  def show(id)
    @decision = Decision.get(id)
    raise NotFound unless @decision
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
