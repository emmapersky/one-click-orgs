class ProposalsController < ApplicationController
  respond_to :html
  
  def index
    # Fetch open proposals
    @proposals = co.proposals.currently_open
    
    # Fetch five most recent decisions
    @decisions = co.decisions.order("id DESC").limit(5)
    
    # Fetch five most recent failed proposals
    @failed_proposals = co.proposals.failed.limit(5)
  end

  def show
    @proposal = co.proposals.find(params[:id])
    respond_with @proposal
  end

  def create
    @proposal = co.proposals.new(params[:proposal])
    @proposal.proposer_member_id = current_user.id #fixme
        
    if @proposal.save
      redirect_to proposal_path(@proposal), :flash => {:notice => "Proposal was successfully created"}
    else
      redirect root_path, :flash => {:error => "Proposal not created"}
    end
  end
  

end # Proposals
