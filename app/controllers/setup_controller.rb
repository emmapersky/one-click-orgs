class SetupController < ApplicationController
  skip_before_filter :ensure_set_up
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_member_active
  skip_before_filter :ensure_organisation_active
  skip_before_filter :ensure_member_inducted
  
  def index
  end
  
  def create_organisation
    # TODO: should set domain clause?
  end
end
