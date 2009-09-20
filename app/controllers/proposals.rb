class Proposals < Application
  # provides :xml, :yaml, :js
  
  def index
    # Fetch open proposals
    @proposals = Proposal.all_open
    
    # Fetch five most recent decisions
    @decisions = Decision.all(:limit => 5, :order => [:id.desc])
    
    # Fetch five most recent failed proposals
    @failed_proposals = Proposal.all_failed[0..4]
        
    render
  end

  def show(id)
    @proposal = Proposal.get(id)
    raise NotFound unless @proposal
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
