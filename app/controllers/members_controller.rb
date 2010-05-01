class MembersController < ApplicationController
  respond_to :html

  def index
    @members = co.members.active
    @pending_members = co.members.pending
    @new_member = co.members.new
    respond_with @members
  end

  def show
    @member = co.members.find(params[:id])
    raise NotFound unless @member
    respond_with @member
  end

  def new
    # only_provides :html
    @member = co.members.new
    respond_with @member
  end

  def edit
    # only_provides :html
    unless current_user.id == params[:id].to_i
      redirect_to(:back, :flash => {:error => "You are not authorized to do this."}) and return
    end
    
    @member = co.members.find(params[:id])
    respond_with @member
  end

  def create
    member = params[:member]
    title = "Add #{member['name']} as a member of #{current_organisation.organisation_name}" # TODO: should default in model
    proposal = co.add_member_proposals.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :parameters => AddMemberProposal.serialize_parameters(member)
    )
    
    if proposal.save
      redirect_to members_path, :notice => "Add Member Proposal successfully created"
    else
      redirect_to members_path, :flash => {:error => "Error creating proposal: #{@member.errors.inspect}"}      
    end
  end


  def update
    id, member = params[:id], params[:member]
    @member = co.members.find(id)
    if @member.update_attributes(member)
       redirect_to member_path(@member), :notice => "Member updated"
    else
      flash[:error] = @member.errors.inspect
      render(:action => :edit)
    end
  end

  def destroy
    @member = co.members.find(params[:id])
    
    title = "Eject #{@member.name} from #{current_organisation.organisation_name}"
    proposal = co.eject_member_proposals.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :parameters => EjectMemberProposal.serialize_parameters('id' => @member.id)
    )
    
    if proposal.save
      redirect_to({:controller => 'one_click', :action => 'control_centre'}, :notice => "Ejection proposal successfully created")
    else
      redirect member_path(@member), :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
    end
  end

end # Members
