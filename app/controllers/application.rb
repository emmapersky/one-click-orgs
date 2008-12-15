class Application < Merb::Controller
  
  before :check_login
  
  def date_format(d)
    d.formatted(:long)
  end
  
  def check_login
    throw :halt, Proc.new{ |p| p.redirect url('login')} unless session('cookie')[:current_user_id]
  end
  
  def current_user
    Member.get(current_user_id)
  end
  
  def current_user_id
    session('cookie')[:current_user_id]
  end
end