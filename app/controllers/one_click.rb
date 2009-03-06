class OneClick < Application
  def index
    @proposals = Decision.all(:open => true)
    render
  end
  
  def constitution
    render
  end
end
