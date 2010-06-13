class OneClickController < ApplicationController
  
  def index
    redirect_to(:action => 'control_centre')
  end
  
  def constitution
    prepare_constitution_view
  end
  
  def control_centre
    # only_provides :html
    
    # Fetch open proposals
    @proposals = Proposal.currently_open
    
    # Fetch five most recent decisions
    @decisions = Decision.order("id DESC").limit(5)
    
    # Fetch five most recent failed proposals
    @failed_proposals = Proposal.failed.limit(5)
    
    @new_proposal = Proposal.new
    @new_member = Member.new
  end
  
  def timeline
    @timeline = [
      Member.all,
      Proposal.all,
      Decision.all
    ].flatten.map(&:to_event).sort{|a, b| b[:timestamp] <=> a[:timestamp]}
  end

end
