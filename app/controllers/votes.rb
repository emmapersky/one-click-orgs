class Votes < Application
  # provides :xml, :yaml, :js

  def index
    @votes = Vote.all
    display @votes
  end

  def show(id)
    @vote = Vote.get(id)
    raise NotFound unless @vote
    display @vote
  end

  def new
    only_provides :html
    @vote = Vote.new
    display @vote
  end

  def edit(id)
    only_provides :html
    @vote = Vote.get(id)
    raise NotFound unless @vote
    display @vote
  end

  def create(vote)
    @vote = Vote.new(vote)
    if @vote.save
      redirect resource(@vote), :message => {:notice => "Vote was successfully created"}
    else
      message[:error] = "Vote failed to be created"
      render :new
    end
  end

  def update(id, vote)
    @vote = Vote.get(id)
    raise NotFound unless @vote
    if @vote.update_attributes(vote)
       redirect resource(@vote)
    else
      display @vote, :edit
    end
  end

  def destroy(id)
    @vote = Vote.get(id)
    raise NotFound unless @vote
    if @vote.destroy
      redirect resource(:votes)
    else
      raise InternalServerError
    end
  end

  def vote_for(id, return_to)
    begin
      current_user.cast_vote(:for, id)
      redirect url(return_to), :message => {:notice => "Vote for proposal cast"}
    rescue Exception => e
      redirect url(return_to), :message => {:notice => "Error casting vote:#{e}"}      
    end
  end
  
  def vote_against(id, return_to)
    begin
      current_user.cast_vote(:against, id)
      redirect url(return_to), :message => {:notice => "Vote against proposal cast"}
    rescue
      redirect url(return_to), :message => {:notice => "Error casting vote"}      
    end    
  end
end 

# Votes
