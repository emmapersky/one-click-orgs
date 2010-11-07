require 'lib/not_found'

class MembersController < ApplicationController

  respond_to :html
  
  before_filter :require_membership_proposal_permission, :only => [:new, :create, :update, :destroy, :change_class]

  def index
    @members = co.members.active
    @pending_members = co.members.pending
    @new_member = co.members.new
    respond_with @members
  end

  def show
    @member = co.members.find(params[:id])
    raise NotFound unless @member
    
    @timeline = [
      @member,
      @member.proposals.all,
      @member.votes.all
    ].flatten.map(&:to_event).compact.sort{|a, b| b[:timestamp] <=> a[:timestamp]}
    
    respond_with @member
  end

  def new
    # only_provides :html
    @member = co.members.new
    respond_with @member
  end

  def edit
    # only_provides :html
    @member = co.members.find(params[:id])
    unless current_user.id == params[:id].to_i
      flash[:error] = "You are not authorized to do this."
      redirect_back_or_default
      return
    end
    respond_with @member
  end

  def create
    member = params[:member]
    title = "Add #{member['first_name']} #{member['last_name']} as a member of #{current_organisation.organisation_name}" # TODO: should default in model
    proposal = co.add_member_proposals.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :parameters => member
    )
    
    if proposal.save
      redirect_to root_path, :notice => "Add Member Proposal successfully created"
    else
      redirect_to root_path, :flash => {:error => "Error creating proposal: #{@member.errors.inspect}"}      
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
      :parameters => {'id' => @member.id}
    )
    
    if proposal.save
      redirect_to({:controller => 'one_click', :action => 'dashboard'}, :notice => "Ejection proposal successfully created")
    else
      redirect member_path(@member), :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
    end
  end
  
  def change_class
    @member = co.members.find(params[:id])
    @new_member_class = co.member_classes.find(params[:member][:member_class_id])
    
    title = "Change member class of #{@member.name} from #{@member.member_class.name} to #{@new_member_class.name}"
    proposal = co.change_member_class_proposals.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :description => params[:description],
      :parameters => ChangeMemberClassProposal.serialize_parameters(
        'id' => @member.id, 
        'member_class_id' => @new_member_class.id)
    )
    
    if proposal.save
      flash[:notice] = "Membership class proposal successfully created"
      redirect_back_or_default(member_path(@member))
    else
      flash[:error] = "Error creating proposal: #{proposal.errors.inspect}"
      redirect_back_or_default(member_path(@member))
    end
  end

private

  def require_membership_proposal_permission
    if !current_user.has_permission(:membership_proposal)
      flash[:error] = "You do not have sufficient permissions to create such a proposal!"
      redirect_back_or_default
    end
  end

end # Members
