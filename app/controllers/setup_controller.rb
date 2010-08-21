class SetupController < ApplicationController
  skip_before_filter :ensure_set_up
  skip_before_filter :ensure_organisation_exists
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_member_active
  skip_before_filter :ensure_organisation_active
  skip_before_filter :ensure_member_inducted
  
  layout 'setup'
  
  def index
    @base_domain = request.host_with_port
  end
  
  def create_base_domain
    @base_domain = params[:base_domain]
    if @base_domain.present?
      Setting[:base_domain] = @base_domain
      flash[:notice] = "Base domain set. Now you can make an organisation."
      redirect_to(new_organisation_path)
    else
      flash[:error] = "You must choose a base domain."
      render(:action => :index)
    end
  end
end
