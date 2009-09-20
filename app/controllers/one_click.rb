class OneClick < Application

  def index
    redirect(url(:action=>'control_centre'))
  end
  
  def constitution
    set_up_instance_variables_for_constitution_view
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
    @timeline = [
      Member.all,
      Proposal.all,
      Decision.all
    ].flatten.map(&:to_event).sort{|a, b| b[:timestamp] <=> a[:timestamp]}
    
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
