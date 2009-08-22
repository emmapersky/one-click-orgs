class OneClick < Application

  def index
    redirect(url(:action=>'control_centre'))
  end
  
  def constitution
    # TODO: Replace these direct calls to Clause.get_current and hard-coded values with neater calls to the Constitution uber-brain class
    @organisation_name = Clause.get_current('organisation_name').text_value
    @objectives = Clause.get_current('objectives').text_value
    @assets = Clause.get_current('assets').boolean_value
    @website = Constitution.domain.blank? ? absolute_url('') : Constitution.domain
    
    @period  = Clause.get_current('voting_period').integer_value
    @voting_period = case @period
    when 0..86400
      pluralize((@period / 60.0).round, 'minute')
    when 86400..(86400 * 5)
      pluralize((@period / 3600.0).round, 'hour')
    else
      pluralize((@period / 3600.0 * 24).round, 'day')
    end
    
    @general_voting_system = Clause.get_current('general_voting_system').text_value
    @general_voting_system_description = case @general_voting_system
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
    
    @membership_voting_system = Clause.get_current('membership_voting_system').text_value
    @membership_voting_system_description = case @membership_voting_system
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
    
    @constitution_voting_system = Clause.get_current('constitution_voting_system').text_value
    @constitution_voting_system_description = case @constitution_voting_system
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
    @new_member = Member.new
        
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
  
  def propose_text_amendment
    proposal = ChangeTextProposal.new(
      :title => "Change #{params['name']} to '#{params['value']}'",
      :proposer_member_id => current_user.id,
      :parameters => ChangeTextProposal.serialize_parameters(
        'name' => params['name'],
        'value' => params['value']
      )
    )
    if proposal.save
      redirect(url(:controller => 'one_click', :action => 'control_centre'), :message => {:notice => "Constitutional amendment proposal succesfully created"})
    else
      redirect('/constitution', :message => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def propose_voting_period_amendment
    if params['new_voting_period']
      proposal = ChangeVotingPeriodProposal.new(
        :title=>"Change voting period",
        :proposer_member_id => current_user.id,
        :parameters => ChangeVotingSystemProposal.serialize_parameters(
          'new_voting_period'=>params['new_voting_period'])
      )      
      if proposal.save
        redirect(url(:controller => 'one_click', :action => 'control_centre'), :message => {:notice => "Constitutional amendment proposal succesfully created"})
      else
        redirect('/constitution', :message => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
      end
    end
  end
  
  def propose_voting_system_amendment
    if params['general_voting_system']
      proposed_system = VotingSystems.get(params['general_voting_system'])      
      current_system = Constitution.voting_system :general
      
      if current_system != proposed_system           
              
        proposal = ChangeVotingSystemProposal.new(
          :title => "change general voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type'=>'general', 'proposed_system'=> proposed_system.simple_name)
        )

        if proposal.save
          redirect url(:controller=>'one_click', :action=>'control_centre'), :message => {:notice=> "Change general voting system proposal successfully created"}
        else
          redirect '/constitution', :message => {:error => "Error creating proposal: #{proposal.errors.inspect}"}      
        end
        
        return
      end
    elsif params['membership_voting_system']
      proposed_system = VotingSystems.get(params['membership_voting_system'])
      current_system = Constitution.voting_system :membership
      
      if current_system != proposed_system
        proposal = ChangeVotingSystemProposal.new(
          :title => "change membership voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type' => 'membership', 'proposed_system' => proposed_system.simple_name)
        )
        
        if proposal.save
          redirect url(:controller=>'one_click', :action=>'control_centre'), :message => {:notice=> "Change membership voting system proposal successfully created"}
        else
          redirect '/constitution', :message => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
    elsif params['constitution_voting_system']
      proposed_system = VotingSystems.get(params['constitution_voting_system'])
      current_system = Constitution.voting_system :constitution
      
      if current_system != proposed_system
        proposal = ChangeVotingSystemProposal.new(
          :title => "change constitution voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type' => 'constitution', 'proposed_system' => proposed_system.simple_name)
        )
        
        if proposal.save
          redirect url(:controller=>'one_click', :action=>'control_centre'), :message => {:notice=> "Change constitution voting system proposal successfully created"}
        else
          redirect '/constitution', :message => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
      
    
    end
    
    redirect '/constitution', :message => {:error => "No changes."}                
  end
end
