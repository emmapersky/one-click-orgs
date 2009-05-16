class Decisions < Application
  def show(id)
    @decision = Decision.get(id)
    raise NotFound unless @decision
    display @decision
  end
end
