class OneClick < Application
  def index
    @proposals = Proposal.all(:open => true)
    render
  end
  
  def constitution
    render
  end
end
