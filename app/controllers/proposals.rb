class Proposals < Application
  # provides :xml, :yaml, :js
  
  def index
    @proposals = Proposal.all(:order=>[:close_date.desc])
    
    completed_votes = current_user.votes
    completed_proposals = {}
    completed_votes.each{|v| completed_proposals[v.proposal_id] = v.for}
    
    @proposals.each do |p| 
      p.completed = completed_proposals.keys.include? p.id
      p.for = completed_proposals[p.id]
    end
    
    @new_proposal = Proposal.new
    display @proposals
    display @new_proposal
  end

  def show(id)
    @proposal = Proposal.get(id)
    raise NotFound unless @proposal
    display @proposal
  end

  def new
    only_provides :html
    @proposal = Proposal.new
    display @proposal
  end

  def edit(id)
    only_provides :html
    @proposal = Proposal.get(id)
    raise NotFound unless @proposal
    display @proposal
  end

  def create(proposal)
    @proposal = Proposal.new(proposal)
    @proposal.proposer_member_id = current_user.id #fixme
        
    if @proposal.save
      redirect url('proposals'), :message => {:notice => "Proposal was successfully created"}
    else
      redirect url('proposals'), :message => {:error => "Proposal not created"}
    end
  end
  
  def update(id, proposal)
    @proposal = Proposal.get(id)
    raise NotFound unless @proposal
    if @proposal.update_attributes(proposal)
       redirect resource(@proposal)
    else
      display @proposal, :edit
    end
  end

  def destroy(id)
    @proposal = Proposal.get(id)
    raise NotFound unless @proposal
    if @proposal.destroy
      redirect resource(:proposals)
    else
      raise InternalServerError
    end
  end

end # Proposals
