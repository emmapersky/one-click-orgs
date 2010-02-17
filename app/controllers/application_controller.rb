class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #should be skip_before in members.rb (http://www.mail-archive.com/merb@googlegroups.com/msg01067.html)
  #but not supported yet
  
  before_filter :ensure_authenticated
  before_filter :ensure_member_active
  before_filter :ensure_organisation_active
   
  def date_format(d)
    d.to_s(:long)
  end
  
  def current_user
    # TODO Convert to new auth system
    # session.user
    return nil
  end
  
  def prepare_constitution_view
    @organisation_name = Organisation.name
    @objectives = Organisation.objectives
    @assets = Organisation.assets
    @website = Organisation.domain

    @period  = Clause.get_integer('voting_period')
    @voting_period = VotingPeriods.name_for_value(@period)

    @general_voting_system = Constitution.voting_system(:general)
    @membership_voting_system = Constitution.voting_system(:membership)
    @constitution_voting_system = Constitution.voting_system(:constitution)
  end
  
  protected
  
  # TODO Replace with actual auth system
  def ensure_authenticated
  end
  
  def ensure_member_active
    # TODO Convert to new auth system
    raise Unauthenticated if current_user && !current_user.active?
  end
  
  def ensure_organisation_active
    return if Organisation.active?
    
    if Organisation.pending?
      redirect_to(:controller => 'induction', :action => 'founding_meeting')
    else
      redirect_to(:controller => 'induction', :action => 'founder')
    end
  end
  
  # EXCEPTIONS
  
  rescue_from NotFound, :with => :render_404
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end
  
  rescue_from Unauthenticated, :with => :handle_unauthenticated
  def handle_unauthenticated
    if Organisation.has_founding_member?
      # TODO Convert to new auth system
      render # unauthenticated, login page      
    else
      redirect_to(:controller => 'induction', :action => 'founder')
    end
  end
end
