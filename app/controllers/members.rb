class Members < Application
  include AsyncJobs
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
    password = @member.new_password!
    if @member.save
      async_job :send_new_member_email, @member.id, password
            
      redirect resource(:members), :message => {:notice=> "Member was successfully created"}
    else
      redirect resource(:members), :message => {:error => "Error creating member: #{@member.errors.inspect}"}
    end
  end
  
  def self.send_new_member_email(member_id, password)
    member = Member.get(member_id)
    send_mail(MembersMailer, :welcome_new_member,
      {:to => member.email, :from => 'info@oneclickor.gs', :subject => 'Your password'},
      {:member => member, :password => password}
    )
  end

  def update(id, member)
    @member = Member.get(id)
    raise NotFound unless @member
    if @member.update_attributes(member)

       redirect resource(@member), :message => {:notice => "Member updated"}
    else
      message[:error] = @member.errors.inspect
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
