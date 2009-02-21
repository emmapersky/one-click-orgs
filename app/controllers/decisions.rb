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

  def new
    only_provides :html
    @decision = Decision.new
    display @decision
  end

  def edit(id)
    only_provides :html
    @decision = Decision.get(id)
    raise NotFound unless @decision
    display @decision
  end

  def create(decision)
    @decision = Decision.new(decision)
    if @decision.save
      redirect url('decisions'), :message => {:notice => "Proposal was successfully created"}
    else
      redirect url('decisions'), :message => {:error => "Proposal not created"}
    end
  end
  
  def create_proposal(decision)
    @proposal = Decision.new(decision)
    @proposal.proposer_member_id = current_user_id
    if @proposal.save
      redirect url('proposals'), :message => {:notice => "Proposal was successfully created"}
    else
      redirect url('proposals'), :message => {:notice => "Proposal not created"}      
    end
  end

  def update(id, decision)
    @decision = Decision.get(id)
    raise NotFound unless @decision
    if @decision.update_attributes(decision)
       redirect resource(@decision)
    else
      display @decision, :edit
    end
  end

  def destroy(id)
    @decision = Decision.get(id)
    raise NotFound unless @decision
    if @decision.destroy
      redirect resource(:decisions)
    else
      raise InternalServerError
    end
  end

end # Decisions
