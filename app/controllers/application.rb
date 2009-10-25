class Application < Merb::Controller
  #should be skip_before in members.rb (http://www.mail-archive.com/merb@googlegroups.com/msg01067.html)
  #but not supported yet
  
  before :ensure_authenticated
  before :ensure_member_active
  before :ensure_organisation_active
   
  def date_format(d)
    d.formatted(:long)
  end
    
  def current_user
    session.user
  end
  
  protected
  
  def ensure_member_active
    raise Unauthenticated if current_user && !current_user.active?
  end
  
  def ensure_organisation_active
    return if Organisation.active?
    
    if Organisation.pending?
      throw :halt, redirect(url(:controller => 'induction', :action => 'founding_meeting'))
    else
      throw :halt, redirect(url(:controller => 'induction', :action => 'founder'))
    end
  end
  
  def set_up_instance_variables_for_constitution_view
    # TODO: Replace these direct calls to Clause.get_current and hard-coded values with neater calls to the Constitution uber-brain class
    @organisation_name = Clause.get_current('organisation_name').text_value
    @objectives = Clause.get_current('objectives').text_value
    @assets = Clause.get_current('assets').boolean_value
    @website = Constitution.domain.blank? ? absolute_url('') : Constitution.domain
    
    @period  = Clause.get_current('voting_period').integer_value
    @voting_period = VotingPeriods.name_for_value(@period)
    
    @general_voting_system = Constitution.voting_system(:general)
    @membership_voting_system = Constitution.voting_system(:membership)
    @constitution_voting_system = Constitution.voting_system(:constitution)
  end
  
end

