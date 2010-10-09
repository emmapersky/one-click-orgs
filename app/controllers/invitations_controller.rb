class InvitationsController < ApplicationController
  skip_before_filter :ensure_authenticated
  
  before_filter :set_up_organisation_name
  
  def edit
    @invitation_code = params[:id]
    @member = Member.find_by_invitation_code(@invitation_code)
    
    unless @member
      render(:action => :not_found)
    end
  end
  
  def update
    @invitation_code = params[:id]
    @member = Member.find_by_invitation_code(@invitation_code)
    @member.attributes = params[:member]
    if @member.save
      @member.clear_invitation_code!
      self.current_user = @member
      flash[:notice] = "Your new password has been saved."
      redirect_to(root_path)
    else
      flash[:error] = "There was a problem with your new details."
      render(:action => :edit)
    end
  end
  
private
  
  def set_up_organisation_name
    @organisation_name = co.organisation_name
  end
end

