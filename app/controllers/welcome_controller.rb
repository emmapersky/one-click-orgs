class WelcomeController < ApplicationController
  skip_before_filter :ensure_member_inducted

  def index
    @organisation_name = co.organisation_name
    prepare_constitution_view
  end

  def induct_member
    member = current_user
    member.inducted = true
    member.save
    redirect_to root_path
  end

  def cancel_membership
    @organisation_name = co.organisation_name
  end
end
