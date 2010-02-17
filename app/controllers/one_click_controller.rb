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
  
  def propose_text_amendment
    proposal = ChangeTextProposal.new(
      :title => "Change #{params[:name]} to '#{params[:value]}'",
      # TODO Convert to new auth sys
      :proposer_member_id => current_user.id,
      :parameters => ChangeTextProposal.serialize_parameters(
        'name' => params[:name],
        'value' => params[:value]
      )
    )
    if proposal.save
      redirect_to({:controller => 'one_click', :action => 'control_centre'}, :notice => "Constitutional amendment proposal succesfully created")
    else
      redirect(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def propose_assets_amendment
    if params[:new_assets_value] == '1'
      title = "Change the constitution to allow holding, transferral and disposal of material assets and intangible assets"
      new_assets_value = true
    else
      title = "Change the constitution to prohibit holding, transferral or disposal of material assets and intangible assets"
      new_assets_value = false
    end
    
    proposal = ChangeBooleanProposal.new(
      :title => title,
      # TODO Convert to new auth system
      :proposer_member_id => current_user.id,
      :parameters => ChangeBooleanProposal.serialize_parameters(
        'name' => 'assets',
        'value' => new_assets_value
      )
    )
    
    if proposal.save
      redirect_to({:controller => 'one_click', :action => 'control_centre'}, :notice => "Constitutional amendment proposal succesfully created")
    else
      redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def propose_voting_period_amendment
    if params[:new_voting_period]
      proposal = ChangeVotingPeriodProposal.new(
        :title=>"Change voting period to #{VotingPeriods.name_for_value(params[:new_voting_period])}",
        # TODO Convert to new auth system
        :proposer_member_id => current_user.id,
        :parameters => ChangeVotingSystemProposal.serialize_parameters(
          'new_voting_period'=>params[:new_voting_period])
      )      
      if proposal.save
        redirect_to({:controller => 'one_click', :action => 'control_centre'}, :notice => "Constitutional amendment proposal succesfully created")
      else
        redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
      end
    end
  end
  
  def propose_voting_system_amendment
    if params[:general_voting_system]
      proposed_system = VotingSystems.get(params[:general_voting_system])      
      current_system = Constitution.voting_system :general
      
      if current_system != proposed_system           
              
        proposal = ChangeVotingSystemProposal.new(
          :title => "change general voting system to #{proposed_system.description}",
          # TODO Convert to new auth system
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type'=>'general', 'proposed_system'=> proposed_system.simple_name)
        )

        if proposal.save
          redirect_to({:controller=>'one_click', :action=>'control_centre'}, :flash => {:notice=> "Change general voting system proposal successfully created"})
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}      
        end

        return
      end
    elsif params[:membership_voting_system]
      proposed_system = VotingSystems.get(params[:membership_voting_system])
      current_system = Constitution.voting_system :membership
      
      if current_system != proposed_system
        proposal = ChangeVotingSystemProposal.new(
          :title => "change membership voting system to #{proposed_system.description}",
          # TODO Convert to new auth system
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type' => 'membership', 'proposed_system' => proposed_system.simple_name)
        )
        
        if proposal.save
          redirect_to({:controller=>'one_click', :action=>'control_centre'}, :flash => {:notice=> "Change membership voting system proposal successfully created"})
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
    elsif params[:constitution_voting_system]
      proposed_system = VotingSystems.get(params[:constitution_voting_system])
      current_system = Constitution.voting_system :constitution
      
      if current_system != proposed_system
        proposal = ChangeVotingSystemProposal.new(
          :title => "change constitution voting system to #{proposed_system.description}",
          # TODO Convert to new auth system
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type' => 'constitution', 'proposed_system' => proposed_system.simple_name)
        )
        
        if proposal.save
          redirect_to({:controller=>'one_click', :action=>'control_centre'}, :flash => {:notice=> "Change constitution voting system proposal successfully created"})
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
      
    
    end
    
    redirect_to constitution_path, :flash => {:error => "No changes."}                
  end
end
