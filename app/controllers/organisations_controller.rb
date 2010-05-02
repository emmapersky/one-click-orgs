class OrganisationsController < ApplicationController
  skip_before_filter :ensure_organisation_exists
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_member_active
  skip_before_filter :ensure_organisation_active
  skip_before_filter :ensure_member_inducted
  
  def new
    @organisation = Organisation.new
  end
  
  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to(:host => @organisation.host, :controller => 'induction', :action => 'founder')
    else
      render(:action => :new)
    end
  end
end
