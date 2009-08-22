class Application < Merb::Controller
  #should be skip_before in members.rb (http://www.mail-archive.com/merb@googlegroups.com/msg01067.html)
  #but not supported yet
  
  before :ensure_founding_member_and_authenticated
  before :ensure_organisation_active
   
  def date_format(d)
    d.formatted(:long)
  end
    
  def current_user
    session.user
  end
  
  def ensure_founding_member_and_authenticated
    if Member.count != 0
      ensure_authenticated
    end
  end
  
  def ensure_organisation_active
    if Organisation.pending?
      throw :halt, redirect(url(:controller => 'induction', :action => 'founding_meeting'))
    elsif Organisation.under_construction?
      throw :halt, redirect(url(:controller => 'induction', :action => 'founder'))
    end
  end
end

