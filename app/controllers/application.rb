class Application < Merb::Controller
  
  before(:check_login)
  
  def date_format(d)
    d.formatted(:long)
  end
  
  def check_login
    if session('cookie')[:current_user_id]
      return true
    else
      redirect url('login')
    end
  end
  
  def current_user
    Member.get(current_user_id)
  end
  
  def current_user_id
    session('cookie')[:current_user_id]
  end
end