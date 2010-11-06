class OrganisationsController < ApplicationController
  skip_before_filter :ensure_organisation_exists
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_member_active
  skip_before_filter :ensure_organisation_active
  skip_before_filter :ensure_member_inducted
  
  before_filter :ensure_not_single_organisation_mode
  
  layout "setup"
  
  def new
    @organisation = Organisation.new
  end
  
  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to(:host => @organisation.host, :controller => 'induction', :action => 'founder')
    else
      flash[:error] = "Sorry, that address is already taken."
      render(:action => :new)
    end
  end

protected

  def ensure_not_single_organisation_mode
    if Setting[:single_organisation_mode] == "true"
      redirect_to root_path
    end
  end
end
