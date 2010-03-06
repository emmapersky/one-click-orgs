class MembersController < ApplicationController
  respond_to :html

  def index
    @members = Member.active
    @new_member = Member.new
    respond_with @members
  end

  def show
    @member = Member.find(params[:id])
    raise NotFound unless @member
    respond_with @member
  end

  def new
    # only_provides :html
    @member = Member.new
    respond_with @member
  end

  def edit
    # only_provides :html
    unless current_user.id == params[:id].to_i
      redirect_to(:back, :flash => {:error => "You are not authorized to do this."})
    end
    
    @member = Member.find(params[:id])
    respond_with @member
  end

  def create
    member = params[:member]
    title = "Add #{member['name']} as a member of #{Organisation.organisation_name}" # TODO: should default in model
    proposal = AddMemberProposal.new(
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
    @member = Member.find(id)
    if @member.update_attributes(member)
       redirect_to member_path(@member), :notice => "Member updated"
    else
      flash[:error] = @member.errors.inspect
      render(:action => :edit)
    end
  end

  def destroy
    @member = Member.find(params[:id])
    
    title = "Eject #{@member.name} from #{Organisation.organisation_name}"
    proposal = EjectMemberProposal.new(
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
