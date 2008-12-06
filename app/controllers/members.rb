class Members < Application
  # provides :xml, :yaml, :js

  def index
    @members = Member.all
    display @members
  end

  def show(id)
    @member = Member.get(id)
    raise NotFound unless @member
    display @member
  end

  def new
    only_provides :html
    @member = Member.new
    display @member
  end

  def edit(id)
    only_provides :html
    @member = Member.get(id)
    raise NotFound unless @member
    display @member
  end

  def create(member)
    @member = Member.new(member)
    if @member.save
      redirect resource(@member), :message => {:notice => "Member was successfully created"}
    else
      message[:error] = "Member failed to be created"
      render :new
    end
  end

  def update(id, member)
    @member = Member.get(id)
    raise NotFound unless @member
    if @member.update_attributes(member)
       redirect resource(@member)
    else
      display @member, :edit
    end
  end

  def destroy(id)
    @member = Member.get(id)
    raise NotFound unless @member
    if @member.destroy
      redirect resource(:members)
    else
      raise InternalServerError
    end
  end

end # Members
