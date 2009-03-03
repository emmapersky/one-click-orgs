class Members < Application
  # provides :xml, :yaml, :js

  def index
    @members = Member.all
    @new_member = Member.new
    display @members
    display @new_member
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
    raise AuthenticationError, 'You are not authorizied to do this' unless current_user.id == id.to_i
    
    @member = Member.get(id)
    raise NotFound unless @member
    display @member
  end

  def create(member)
    @member = Member.new(member)
    if @member.save
      redirect resource(:members), :message => {:notice => "Member was successfully created"}
    else
      redirect resource(:members), :message => {:error => "Error creating member"}
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
