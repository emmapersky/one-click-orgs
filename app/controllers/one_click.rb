class OneClick < Application
  def constitution
    # TODO: Replace these direct calls to Clause.get_current and hard-coded values with neater calls to the Constitution uber-brain class
    @organisation_name = Clause.get_current('organisation_name').text_value
    @objectives = Clause.get_current('objectives').text_value
    @assets = Clause.get_current('assets').boolean_value
    @website = Clause.domain.blank? ? absolute_url('') : Clause.domain
    
    period  = Clause.get_current('voting_period').integer_value
    @voting_period = case period
    when 0..86400
      "#{(period / 60.0).round} minutes"
    when 86400..(86400 * 5)
      "#{(period / 3600.0).round} hours"
    else
      "#{(period / 3600.0 * 24).round} days"
    end
    
    @general_voting_system = case Clause.get_current('general_voting_system').text_value
    when "RelativeMajority"
      "receives Supporting Votes from more than half of the Members during the Voting Period; or when more Supporting Votes than Opposing Votes have been received for the Proposal at the end of the Voting Period."
    when "Veto"
      "receives no Opposing Votes during the Voting Period."
    when "AbsoluteMajority"
      "receives Supporting Votes from more than half of Members during the Voting Period."
    when "AbsoluteTwoThirdsMajority"
      "receives Supporting Votes from more than two thirds of Members during the Voting Period."
    when "Unanimous"
      "receives Supporting Votes from all Members during the Voting Period."
    end
    
    @membership_voting_system = case Clause.get_current('membership_voting_system').text_value
    when "RelativeMajority"
      "receives Supporting Votes from more than half of the Members during the Voting Period; or when more Supporting Votes than Opposing Votes have been received for the Proposal at the end of the Voting Period."
    when "Veto"
      "receives no Opposing Votes during the Voting Period."
    when "AbsoluteMajority"
      "receives Supporting Votes from more than half of Members during the Voting Period."
    when "AbsoluteTwoThirdsMajority"
      "receives Supporting Votes from more than two thirds of Members during the Voting Period."
    when "Unanimous"
      "receives Supporting Votes from all Members during the Voting Period."
    end
    
    @constitution_voting_system = case Clause.get_current('constitution_voting_system').text_value
    when "RelativeMajority"
      "receives Supporting Votes from more than half of the Members during the Voting Period; or when more Supporting Votes than Opposing Votes have been received for the Proposal at the end of the Voting Period."
    when "Veto"
      "receives no Opposing Votes during the Voting Period."
    when "AbsoluteMajority"
      "receives Supporting Votes from more than half of Members during the Voting Period."
    when "AbsoluteTwoThirdsMajority"
      "receives Supporting Votes from more than two thirds of Members during the Voting Period."
    when "Unanimous"
      "receives Supporting Votes from all Members during the Voting Period."
    end
        
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
    @new_proposal = Proposal.new
        
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
  
  def propose_amendment
  
    if proposed_system = params['general_voting_system']      
      
        current_system = Clause.get_current('general_voting_system')
        if current_system.text_value != proposed_system           
          proposal = ChangeVotingSystemProposal.new(
            :title => "change general voting system to #{proposed_system}",
            :proposer_member_id => current_user.id,
            :parameters => ChangeVotingSystemProposal.serialize_parameters('type'=>'general', 'proposed_system'=> proposed_system)
          )

          if proposal.save
            redirect url(:controller=>'one_click', :action=>'control_centre'), :message => {:notice=> "Change voting system proposal successfully created"}
          else
            redirect '/constitution', :message => {:error => "Error creating proposal: #{proposal.errors.inspect}"}      
          end
          return
        end
    end
    
    redirect '/constitution', :message => {:error => "No changes."}                
  end
end
