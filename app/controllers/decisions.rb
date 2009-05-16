class Decisions < Application
  
  def index
    @decisions = Decision.all    
    display @decisions
  end
end