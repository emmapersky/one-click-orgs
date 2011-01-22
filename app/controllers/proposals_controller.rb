class ProposalsController < ApplicationController

  respond_to :html
  
  before_filter :require_freeform_proposal_permission, :only => [:create]
  
  before_filter :require_constitutional_proposal_permission, :only => [
    :create_text_amendment, :create_assets_amendment, :create_voting_period_amendment,
    :create_voting_system_amendment]
  
  before_filter :require_found_organisation_permission, :only => [:found_organisation_proposal]
  before_filter :ensure_organisation_pending, :only => [ :found_organisation_proposal ]
  
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
    @comments = @proposal.comments
    @comment = Comment.new
    respond_with @proposal
  end

  # Freeform proposal
  def create
    @proposal = co.proposals.new(params[:proposal])
    @proposal[:type] = Proposal # Bug #138, cf. http://www.simple10.com/rails-3-sti/
    @proposal.proposer_member_id = current_user.id #fixme
        
    if @proposal.start
      # Freeform proposal has no need for direct enactment logic during pending stage.
      redirect_to proposal_path(@proposal), :flash => {:notice => "Proposal was successfully created"}
    else
      redirect root_path, :flash => {:error => "Proposal not created"}
    end
  end
  
  def propose_foundation
    proposal = co.found_organisation_proposals.new(
      :title => "Proposal to Found #{co.name}",
      :proposer_member_id => current_user.id
    )
    if proposal.start
      # Founding proposal has no need for direct enactment logic during pending stage.
      
      # TODO: Why do we change the founding member's member class here?
      current_user.member_class = co.member_classes.find_by_name('Member')
      current_user.save!
      
      co.proposed!
      co.save
      
      redirect_to({:controller => 'one_click', :action => 'dashboard'}, :notice => "The founding vote has now begun.")
    else
      redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def create_text_amendment
    proposal = co.change_text_proposals.new(
      :title => "Change #{params[:name].humanize.downcase} to '#{params[:value]}'",
      :proposer_member_id => current_user.id,
      :parameters => {
        'name' => params[:name],
        'value' => params[:value]
      }
    )
    if proposal.start
      if proposal.accepted?
        redirect_to(constitution_path, :notice => "Constitutional change was made")
      else
        redirect_to({:controller => 'one_click', :action => 'dashboard'}, :notice => "Constitutional amendment proposal successfully created")
      end
    else
      redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def create_assets_amendment
    if params[:new_assets_value] == '1'
      title = "Change the constitution to allow holding, transferral and disposal of material assets and intangible assets"
      new_assets_value = true
    else
      title = "Change the constitution to prohibit holding, transferral or disposal of material assets and intangible assets"
      new_assets_value = false
    end
    
    proposal = co.change_boolean_proposals.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :parameters => {
        'name' => 'assets',
        'value' => new_assets_value
      }
    )
    
    if proposal.start
      if proposal.accepted?
        redirect_to(constitution_path, :notice => "Constitutional change was made")
      else
        redirect_to({:controller => 'one_click', :action => 'dashboard'}, :notice => "Constitutional amendment proposal successfully created")
      end
    else
      redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def create_voting_period_amendment
    if params[:new_voting_period]
      proposal = co.change_voting_period_proposals.new(
        :title=>"Change voting period to #{VotingPeriods.name_for_value(params[:new_voting_period])}",
        :proposer_member_id => current_user.id,
        :parameters => {'new_voting_period'=>params[:new_voting_period]}
      )
      if proposal.start
        if proposal.accepted?
          redirect_to(constitution_path, :notice => "Constitutional change was made")
        else
          redirect_to({:controller => 'one_click', :action => 'dashboard'}, :notice => "Constitutional amendment proposal successfully created")
        end
      else
        redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
      end
    end
  end
  
  def create_voting_system_amendment
    if params[:general_voting_system]
      proposed_system = VotingSystems.get(params[:general_voting_system])      
      current_system = co.constitution.voting_system :general
      
      if current_system != proposed_system           
              
        proposal = co.change_voting_system_proposals.new(
          :title => "Change general voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => {'type'=>'general', 'proposed_system'=> proposed_system.simple_name}
        )

        if proposal.start
          if proposal.accepted?
            redirect_to(constitution_path, :flash => {:notice=> "General voting system change was made"})
          else
            redirect_to({:controller=>'one_click', :action=>'dashboard'}, :flash => {:notice=> "Change general voting system proposal successfully created"})
          end
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}      
        end

        return
      end
    elsif params[:membership_voting_system]
      proposed_system = VotingSystems.get(params[:membership_voting_system])
      current_system = co.constitution.voting_system :membership
      
      if current_system != proposed_system
        proposal = co.change_voting_system_proposals.new(
          :title => "Change membership voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => {'type' => 'membership', 'proposed_system' => proposed_system.simple_name}
        )
        
        if proposal.start
          if proposal.accepted?
            redirect_to(constitution_path, :flash => {:notice=> "Membership voting system change was made"})
          else
            redirect_to({:controller=>'one_click', :action=>'dashboard'}, :flash => {:notice=> "Change membership voting system proposal successfully created"})
          end
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
    elsif params[:constitution_voting_system]
      proposed_system = VotingSystems.get(params[:constitution_voting_system])
      current_system = co.constitution.voting_system :constitution
      
      if current_system != proposed_system
        proposal = co.change_voting_system_proposals.new(
          :title => "Change constitution voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => {'type' => 'constitution', 'proposed_system' => proposed_system.simple_name}
        )
        
        if proposal.start
          if proposal.accepted?
            redirect_to(constitution_path, :flash => {:notice=> "Constitution voting system change was made"})
          else
            redirect_to({:controller=>'one_click', :action=>'dashboard'}, :flash => {:notice=> "Change constitution voting system proposal successfully created"})
          end
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
    end
    
    redirect_to constitution_path, :flash => {:error => "No changes."}                
  end

private

  def require_freeform_proposal_permission
    if !current_user.has_permission(:freeform_proposal)
      flash[:error] = "You do not have sufficient permissions to create such a proposal!"
      redirect_back_or_default
    end
  end
  
  def require_constitutional_proposal_permission
    if !current_user.has_permission(:constitution_proposal)
      flash[:error] = "You do not have sufficient permissions to create such a proposal!"
      redirect_back_or_default
    end
  end
  
  def require_found_organisation_permission
    if !current_user.has_permission(:found_organisation_proposal)
      flash[:error] = "You do not have sufficient permissions to create such a proposal!"
      redirect_back_or_default
    end
  end

end # Proposals
