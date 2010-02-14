class Welcome < Application
  
  include Merb::ConstitutionHelper
  skip_before :ensure_member_inducted

  def index
    @organisation_name = Organisation.name
    prepare_constitution_view
    render
  end

  def induct_member
    member = current_user
    member.inducted = true
    member.save
    redirect('/')
  end

  def cancel_membership
    @organisation_name = Organisation.name
    render
  end
  
end