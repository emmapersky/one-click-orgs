class Decisions < Application
  # provides :xml, :yaml, :js

  def index
    @decisions = Decision.all
    display @decisions
  end

  def show(id)
    @decision = Decision.get(id)
    raise NotFound unless @decision
    display @decision
  end

  def new
    only_provides :html
    @decision = Decision.new
    display @decision
  end

  def edit(id)
    only_provides :html
    @decision = Decision.get(id)
    raise NotFound unless @decision
    display @decision
  end

  def create(decision)
    @decision = Decision.new(decision)
    if @decision.save
      redirect resource(@decision), :message => {:notice => "Decision was successfully created"}
    else
      message[:error] = "Decision failed to be created"
      render :new
    end
  end

  def update(id, decision)
    @decision = Decision.get(id)
    raise NotFound unless @decision
    if @decision.update_attributes(decision)
       redirect resource(@decision)
    else
      display @decision, :edit
    end
  end

  def destroy(id)
    @decision = Decision.get(id)
    raise NotFound unless @decision
    if @decision.destroy
      redirect resource(:decisions)
    else
      raise InternalServerError
    end
  end

end # Decisions
