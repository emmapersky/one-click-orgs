class InductionController < ApplicationController
  before_filter :assign_organisation
  skip_before_filter :ensure_organisation_active
  before_filter :check_active_organisation
  
  before_filter :ensure_authenticated, :except => [:founder, :create_founder]

  PENDING_ACTIONS = [:founding_meeting, :confirm_founding_meeting, :restart_induction]
  CONSTRUCTION_ACTIONS = [:founder, :create_founder, :members, :create_members, :organisation_details, :create_organisation_details, :confirm_agenda]
  
  before_filter :ensure_organisation_under_construction, :only => CONSTRUCTION_ACTIONS
  before_filter :ensure_organisation_pending, :only => PENDING_ACTIONS

  # UNDER CONSTRUCTION    
  def founder
    @founder = co.members.first || co.members.new
  end
  
  def create_founder
    # Detect the server domain if not already set
    # TODO fix for multi-tenancy
    # if co.domain.blank?
    #   co.clauses.set_text(:domain, "#{request.protocol}#{request.host}")
    # end
    
    @founder = co.members.first || co.members.new
    @founder.attributes = params[:member]
    if @founder.save
      self.current_user = @founder
      redirect_to(:action => 'organisation_details')
    else
      redirect_to({:action => 'founder'}, :flash => {:error => "There was a problem with your details: #{@founder.errors.full_messages.to_sentence}"})
    end
  end
  
  def organisation_details
    @organisation_name = co.organisation_name
    @objectives = co.objectives
    # FIXME This will erroneously revert the assets setting to true if co.assets is already set to false
    @assets = co.assets || true
  end
  
  def create_organisation_details
    organisation_name = co.clauses.get_current('organisation_name') || co.clauses.new(:name => 'organisation_name')
    organisation_name.text_value = params[:organisation_name]
    organisation_name.save!
  
    objectives = co.clauses.get_current('objectives') || co.clauses.new(:name => 'objectives')
    objectives.text_value = params[:objectives]
    objectives.save!
    
    assets = co.clauses.get_current('assets') || co.clauses.new(:name => 'assets')
    assets.boolean_value = params[:assets] == '1'
    assets.save!
    
    if params[:organisation_name].blank? || params[:objectives].blank?
        redirect_to({:action => 'organisation_details'}, :flash => {:error => "You must fill in the organisation name and objects."})
    else
      redirect_to(:action => 'members')
    end
  end
  
  def members
    # Find the first fifteen members after the founding member,
    # creating new empty members as necessary.
    @members = co.members.all
    @founder = @members.shift
    while @members.length < 15 do
      @members.push(co.members.new)
    end
  end
  
  def create_members
    params[:members].each_value do |member_params|
      if member_params[:first_name].present? && member_params[:last_name].present? && member_params[:email].present?
        if member_params[:id].blank?
          member = co.members.new
          member.new_password!
        else
          member = co.members.find(member_params[:id])
        end
        member.first_name = member_params[:first_name]
        member.last_name = member_params[:last_name]
        member.email = member_params[:email]
        member.member_class = MemberClass.find(member_params[:member_class_id])
        member.save!
      elsif !member_params[:id].blank?
        # We get here if the name and email fields have been cleared
        # for a memeber that's already been saved to the database.
        # Treat this as a deletion.
        co.members.find(member_params[:id]).destroy
      end
    end
    redirect_to(:action => 'voting_settings')
  end
  
  def voting_settings
    @voting_period = co.clauses.get_integer(:voting_period) or 259200
    @general_voting_system = co.clauses.get_text(:general_voting_system) or 'RelativeMajority'
    @membership_voting_system = co.clauses.get_text(:membership_voting_system) or 'AbsoluteTwoThirdsMajority'
    @constitution_voting_system = co.clauses.get_text(:constitution_voting_system) or 'AbsoluteTwoThirdsMajority'
  end
  
  def create_voting_settings
    voting_period = co.clauses.get_current('voting_period') || co.clauses.new(:name => 'voting_period')
    voting_period.integer_value = params[:voting_period]
    voting_period.save!
    
    general_voting_system = co.clauses.get_current('general_voting_system') || co.clauses.new(:name => 'general_voting_system')
    general_voting_system.text_value = params[:general_voting_system]
    general_voting_system.save!
    
    membership_voting_system = co.clauses.get_current('membership_voting_system') || co.clauses.new(:name => 'membership_voting_system')
    membership_voting_system.text_value = params[:membership_voting_system]
    membership_voting_system.save!
    
    constitution_voting_system = co.clauses.get_current('constitution_voting_system') || co.clauses.new(:name => 'constitution_voting_system')
    constitution_voting_system.text_value = params[:constitution_voting_system]
    constitution_voting_system.save!
    
    redirect_to(:action => 'preview_constitution')
  end
  
  def preview_constitution
    prepare_constitution_view
  end
  
  def founding_meeting_details
    @founding_meeting_date = co.clauses.get_text('founding_meeting_date')
    @founding_meeting_time = co.clauses.get_text('founding_meeting_time')
    @founding_meeting_location = co.clauses.get_text('founding_meeting_location')
  end
  
  def create_founding_meeting_details
    founding_meeting_date = co.clauses.get_current('founding_meeting_date') || co.clauses.new(:name => 'founding_meeting_date')
    founding_meeting_date.text_value = params[:date]
    founding_meeting_date.save!
  
    founding_meeting_time = co.clauses.get_current('founding_meeting_time') || co.clauses.new(:name => 'founding_meeting_time')
    founding_meeting_time.text_value = params[:time]
    founding_meeting_time.save!
  
    founding_meeting_location = co.clauses.get_current('founding_meeting_location') || co.clauses.new(:name => 'founding_meeting_location')
    founding_meeting_location.text_value = params[:location]
    founding_meeting_location.save!
    
    if params[:date].blank? || params[:time].blank? || params[:location].blank?
      redirect_to({:action => 'founding_meeting_details'}, :flash => {:error => "You must fill in a date, time and location for the founding meeting."})
    else
      redirect_to(:action => 'preview_agenda')
    end
  end
  
  def preview_agenda
    @organisation_name = co.organisation_name
    @founding_meeting_location = co.clauses.get_text('founding_meeting_location')
    @founding_meeting_date = co.clauses.get_text('founding_meeting_date')
    @founding_meeting_time = co.clauses.get_text('founding_meeting_time')
    
    @members = co.members.active
  end
    
  # Sends the constitution and agenda to founding members,
  # and moves the organisation to 'pending' state.
  def confirm_agenda
    organisation_state = co.clauses.get_current('organisation_state') || co.clauses.new(:name => 'organisation_state')
    organisation_state.text_value = 'pending'
    organisation_state.save!
    
    # Send emails with founding meeting agenda
    co.members.all.each do |member|
      InductionController.send_later(:send_agenda_email, member)
    end
    
    redirect_to(:action => 'founding_meeting')
  end
  
  # PENDING STATE  
  
  # Form to confirm that the founding meeting happened,
  # and select which founding members voted in favour.
  def founding_meeting
    @organisation_name = co.organisation_name
    @founding_member = co.members.first
    @other_members = co.members.all; @other_members.shift
  end
  
  # Remove any founding members that did not vote in favour,
  # and move organisation to 'active' state.
  def confirm_founding_meeting
    other_members = co.members.all.to_a[1..-1]
    confirmed_member_ids = if params[:members].respond_to?(:keys)
      params[:members].keys.map(&:to_i)
    else
      []
    end
    
    other_members.each do |member|
      unless confirmed_member_ids.include?(member.id)
        member.destroy
        other_members -= [member]
      end
    end
    
    organisation_state = co.clauses.get_current('organisation_state')
    organisation_state.text_value = "active"
    organisation_state.save!
    
    #now, send out emails to confirm creation of all members
    other_members.each do |m|
      Rails.logger.info("sending welcome message to #{m}")
      m.new_password!
      m.save
      m.send_welcome
    end
      
    redirect_to(:controller => 'one_click', :action => 'dashboard')
  end
  
  # Moves the organisation back from 'pending' state, to
  # allow editing of org details.
  def restart_induction
    co.clauses.get_current('founding_meeting_date').destroy
    co.clauses.get_current('founding_meeting_time').destroy
    co.clauses.get_current('founding_meeting_location').destroy
    
    co.clauses.get_current('organisation_state').destroy
    
    redirect_to(:action => 'organisation_details')
  end
  
private
  def assign_organisation
    @co = co
  end
  
  def check_active_organisation
    if co.active?
      if co.has_founding_member?
        redirect_to(:controller => 'one_click', :action => 'dashboard')
      else
        co.under_construction!
        raise "ERROR: organisation marked as active but no members present - reset"
      end
    end
  end
  
  def ensure_organisation_under_construction
    redirect_to(:action => 'founding_meeting') unless co.under_construction?
  end
  
  def ensure_organisation_pending
    redirect_to(:action => 'founder') unless co.pending?
  end

public
  
  def self.send_agenda_email(member)
    co = member.organisation
    organisation_name = co.organisation_name
    founding_meeting_location = co.clauses.get_text('founding_meeting_location')
    founding_meeting_date = co.clauses.get_text('founding_meeting_date')
    founding_meeting_time = co.clauses.get_text('founding_meeting_time')
    founding_member_name = co.members.first.name
    members = co.members.all
    
    InductionMailer.notify_agenda(
      {
        :member => member,
        :organisation_name => organisation_name,
        :founding_meeting_location => founding_meeting_location,
        :founding_meeting_date => founding_meeting_date,
        :founding_meeting_time => founding_meeting_time,
        :founding_member_name => founding_member_name,
        :members => members
      }
    ).deliver
  end
end
