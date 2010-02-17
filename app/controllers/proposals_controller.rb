class ProposalsController < ApplicationController
  # respond_to :xml, :yaml, :js
  
  def index
    # Fetch open proposals
    @proposals = Proposal.currently_open
    
    # Fetch five most recent decisions
    @decisions = Decision.order("id DESC").limit(5)
    
    # Fetch five most recent failed proposals
    @failed_proposals = Proposal.failed.limit(5)
  end

  def show
    @proposal = Proposal.find(params[:id])
    respond_with @proposal
  end

  def create
    @proposal = Proposal.new(params[:proposal])
    # TODO Convert to new auth system
    @proposal.proposer_member_id = current_user.id #fixme
        
    if @proposal.save
      redirect_to proposal_path(@proposal), :flash => {:notice => "Proposal was successfully created"}
    else
      redirect root_path, :flash => {:error => "Proposal not created"}
    end
  end
  

end # Proposals
