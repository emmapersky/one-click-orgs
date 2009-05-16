class OneClick < Application
  def constitution
    @new_proposal = Proposal.new
    render
  end
  
  def control_centre
    only_provides :html
    
    # Fetch open proposals, with current user's status on each
    @proposals = Proposal.all_open
    
    completed_votes = current_user.votes
    completed_decisions = {}
    completed_votes.each{|v| completed_decisions[v.proposal_id] = v.for}
    
    @proposals.each do |p| 
      p.completed = completed_decisions.keys.include? p.id
      p.for = completed_decisions[p.id]
    end
    
    # Fetch five most recent decisions
    @decisions = Decision.all(:limit => 5, :order => [:id.desc])
    
    # Fetch five most recent failed proposals
    @failed_proposals = Proposal.all_failed[0..4]
    
    render
  end
  
  def timeline
    members = Member.all
    proposals = Proposal.all
    decisions = Decision.all
    failed_proposals = Proposal.all_failed
    
    @timeline = []
    @timeline += members.map do |member|
      {:timestamp => member.created_at, :object => member, :kind => :new_member}
    end
    @timeline += proposals.map do |proposal|
      {:timestamp => proposal.creation_date, :object => proposal, :kind => :proposal}
    end
    @timeline += decisions.map do |decision|
      {:timestamp => decision.proposal.close_date, :object => decision, :kind => :decision}
    end
    @timeline += failed_proposals.map do |failed_proposal|
      {:timestamp => failed_proposal.close_date, :object => failed_proposal, :kind => :failed_proposal}
    end
    @timeline.sort!{|a, b| b[:timestamp] <=> a[:timestamp]}
    
    render
  end
end
