class OneClick < Application
  def index
    @proposals = Decision.all(:open => true)
    render
  end
  
  def constitution
    render
  end
  
  def control_centre
    only_provides :html
    
    # Fetch open proposals, with current user's status on each
    @proposals = Decision.all_proposals
    
    completed_votes = current_user.votes
    completed_decisions = {}
    completed_votes.each{|v| completed_decisions[v.decision_id] = v.for}
    
    @proposals.each do |p| 
      p.completed = completed_decisions.keys.include? p.id
      p.for = completed_decisions[p.id]
    end
    
    # Fetch five most recent decisions
    @decisions = Decision.all_decisions[0..4]
    
    # Fetch five most recent failed proposals
    @failed_proposals = Decision.all_failed_proposals[0..4]
    
    render
  end
end
