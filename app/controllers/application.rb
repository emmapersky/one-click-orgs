class Application < Merb::Controller
  #should be skip_before in members.rb (http://www.mail-archive.com/merb@googlegroups.com/msg01067.html)
  #but not supported yet
  
  before :ensure_authenticated
  before :ensure_member_active
  before :ensure_organisation_active
  before :ensure_member_inducted
   
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
  
  def ensure_member_inducted
    throw :halt, :redirect_to_welcome_new_member if Organisation.active? && current_user && !current_user.inducted
  end
  
  def redirect_to_welcome_new_member
    redirect('/welcome')
  end
  
end

