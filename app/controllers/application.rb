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
    @organisation_name = Organisation.name
    @objectives = Organisation.objectives
    @assets = Organisation.assets
    @website = Organisation.domain
    
    @period  = Clause.get_integer('voting_period')
    @voting_period = VotingPeriods.name_for_value(@period)
    
    @general_voting_system = Clause.get_text('general_voting_system')
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
    
    @membership_voting_system = Clause.get_text('membership_voting_system')
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
    
    @constitution_voting_system = Clause.get_text('constitution_voting_system')
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
  end
  
end

