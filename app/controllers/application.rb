class Application < Merb::Controller
  #should be skip_before in members.rb (http://www.mail-archive.com/merb@googlegroups.com/msg01067.html)
  #but not supported yet
  
  before :ensure_authenticated
   
  def date_format(d)
    d.formatted(:long)
  end
    
  def current_user
    session.user
  end
end

