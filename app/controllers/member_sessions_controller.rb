class MemberSessionsController < ApplicationController
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_member_active
  skip_before_filter :ensure_organisation_active
  skip_before_filter :ensure_member_inducted
  
  def new
  end
  
  def create
    self.current_user = co.members.authenticate(params[:email], params[:password])
    if current_user
      flash[:notice] = "Authenticated successfully"
      redirect_back_or_default
    else
      flash[:error] = "Email or password were incorrect"
      render(:action => :new)
    end
  end
  
  def destroy
    reset_session
    flash[:notice] = "Logged Out"
    redirect_to(root_path)
  end
end
