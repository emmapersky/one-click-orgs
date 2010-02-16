class Members < Application
  include AsyncJobs
  # provides :xml, :yaml, :js
  
  def index
    @members = Member.all.active
    @new_member = Member.new
    display @members
    display @new_member
  end

  def show
    @member = Member.get(params[:id])
    raise NotFound unless @member
    display @member
  end

  def new
    only_provides :html
    @member = Member.new
    display @member
  end

  def edit
    only_provides :html
    raise ::Merb::ControllerExceptions::Unauthorized, 'You are not authorized to do this' unless current_user.id == params[:id].to_i
    
    @member = Member.get(params[:id])
    raise NotFound unless @member
    display @member
  end

  def create
    member = params[:member]
    title = "Add #{member['name']} as a member of #{Organisation.name}" # TODO: should default in model
    proposal = AddMemberProposal.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :parameters => AddMemberProposal.serialize_parameters(member)
    )
    
    if proposal.save
      redirect resource(:members), :message => {:notice=> "Add Member Proposal successfully created"}
    else
      redirect resource(:members), :message => {:error => "Error creating proposal: #{@member.errors.inspect}"}      
    end
  end


  def update
    id, member = params[:id], params[:member]
    @member = Member.get(id)
    raise NotFound unless @member
    if @member.update_attributes(member)

       redirect resource(@member), :message => {:notice => "Member updated"}
    else
      message[:error] = @member.errors.inspect
      display @member, :edit
    end
  end

  def destroy
    @member = Member.get(params[:id])
    raise NotFound unless @member
    
    title = "Eject #{@member.name} from #{Organisation.name}"
    proposal = EjectMemberProposal.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :parameters => EjectMemberProposal.serialize_parameters('id' => @member.id)
    )
    
    if proposal.save
      redirect url(:controller=>'one_click', :action=>'control_centre'), :message => {:notice=> "Ejection proposal successfully created"}
    else
      redirect resource(@member), :message => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
    end
  end

end # Members
