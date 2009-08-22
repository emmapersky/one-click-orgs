class Induction < Application

  skip_before :ensure_organisation_active
  before :ensure_authenticated, :exclude => [:founder, :create_founder]

  PENDING_ACTIONS = [:confirm_agenda, :founding_meeting, :confirm_founding_meeting, :restart_induction]
  CONSTRUCTION_ACTIONS = [ :founder, :create_founder, :members, :create_members, :organisation_details, :create_organisation_details]
  
  before :ensure_organisation_under_construction, :only => CONSTRUCTION_ACTIONS
  before :ensure_organisation_pending, :only => PENDING_ACTIONS

  # UNDER CONSTRUCTION    
  def founder
    @founder = Member.new
    render
  end
  
  def create_founder
    Member.create(params[:member])
    redirect(url(:action => 'organisation_details'))
  end
  
  def organisation_details
    render
  end
  
  def create_organisation_details
    organisation_name = Clause.get_current('organisation_name') || Clause.new(:name => 'organisation_name')
    organisation_name.text_value = params[:organisation_name]
    organisation_name.save
    
    objectives = Clause.get_current('objectives') || Clause.new(:name => 'objectives')
    objectives.text_value = params[:objectives]
    objectives.save
    
    assets = Clause.get_current('assets') || Clause.new(:name => assets)
    assets.boolean_value = params[:assets]
    assets.save
    
    redirect(url(:action => 'members'))
  end
  
  def members
    render
  end
  
  def create_members
    
  end
  
  def voting_settings
    render
  end
  
  def create_voting_settings
  end
  
  def preview_constitution
    render
  end
  
  def founding_meeting_details
    render
  end
  
  def create_founding_meeting_details
  end
  
  def preview_agenda
    render
  end
    
  # Sends the constitution and agenda to founding members,
  # and moves the organisation to 'pending' state.
  def confirm_agenda
  end
  
  # PENDING STATE  
  
  # Form to confirm that the founding meeting happened,
  # and select which founding members voted in favour.
  def founding_meeting
    render
  end
  
  # Remove any founding members that did not vote in favour,
  # and move organisation to 'active' state.
  def confirm_founding_meeting
  end
  
  # Moves the organisation back from 'pending' state, to
  # allow editing of org details.
  def restart_induction
  end

private

  def ensure_organisation_under_construction
    if Organisation.pending?
      throw :halt, redirect(url(:action => 'founding_meeting'))
    elsif Organisation.active?
      throw :halt, redirect(url(:controller => 'one_click', :action => 'control_centre'))
    end
  end
  
  def ensure_organisation_pending
    if Organisation.under_construction?
      throw :halt, redirect(url(:action => 'founder'))
    elsif Organisation.active?
      throw :halt, redirect(url(:controller => 'one_click', :action => 'control_centre'))
    end
  end

end
