class OneClick < Application
#  before :check_login, :exclude => [:authenticate, :login]

  def index
    @proposals = Decision.all(:open => true)
    render
  end
  
  def login
    render 
  end
  
  def logout
    session.user = nil
    redirect url('login')
  end
  
  def constitution
    render
  end
end
