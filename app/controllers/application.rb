class Application < Merb::Controller
#  before :check_login
 before :ensure_authenticated
   
  def date_format(d)
    d.formatted(:long)
  end
    
  def current_user
    session.user
  end
end

