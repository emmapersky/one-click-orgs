class OneClickController < ApplicationController
  before_filter :current_organisation
  
  def index
    redirect_to(:action => 'dashboard')
  end
  
  def constitution
    prepare_constitution_view
  end
  
  def dashboard
    # only_provides :html
    
    # Fetch open proposals
    @proposals = co.proposals.currently_open
    
    @new_proposal = co.proposals.new
    @new_member = co.members.new
    
    @timeline = [
      co.members.all,
      co.proposals.all,
      co.decisions.all
    ].flatten.map(&:to_event).compact.sort{|a, b| b[:timestamp] <=> a[:timestamp]}
  end
  
  def settings
    prepare_constitution_view
  end
  
end
