class OneClickController < ApplicationController
  
  def index
    redirect_to(:action => 'dashboard')
  end
  
  def constitution
    prepare_constitution_view
  end
  
  def dashboard
    # only_provides :html
    
    # Fetch open proposals
    @proposals = co.proposals.currently_open
    
    # Fetch five most recent decisions
    @decisions = co.decisions.order("id DESC").limit(5)
    
    # Fetch five most recent failed proposals
    @failed_proposals = co.proposals.failed.limit(5)
    
    @new_proposal = co.proposals.new
    @new_member = co.members.new
  end
  
  def timeline
    @timeline = [
      co.members.all,
      co.proposals.all,
      co.decisions.all
    ].flatten.map(&:to_event).sort{|a, b| b[:timestamp] <=> a[:timestamp]}
  end
end
