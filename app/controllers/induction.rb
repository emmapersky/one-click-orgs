class Induction < Application
  include AsyncJobs
  include Merb::ConstitutionHelper
  
  layout :induction

  skip_before :ensure_organisation_active
  before :check_active_organisation
  
  before :ensure_authenticated, :exclude => [:founder, :create_founder]

  PENDING_ACTIONS = [:founding_meeting, :confirm_founding_meeting, :restart_induction]
  CONSTRUCTION_ACTIONS = [:founder, :create_founder, :members, :create_members, :organisation_details, :create_organisation_details, :confirm_agenda]
  
  before :ensure_organisation_under_construction, :only => CONSTRUCTION_ACTIONS
  before :ensure_organisation_pending, :only => PENDING_ACTIONS

  # UNDER CONSTRUCTION    
  def founder
    @founder = Member.first || Member.new
    render
  end
  
  def create_founder
    # Detect the server domain if not already set
    if Organisation.domain.blank?
      Clause.set_text(:domain, "#{request.protocol}://#{request.host}")
    end
    
    @founder = Member.first || Member.new
    @founder.attributes = params[:member]
    if @founder.save
      session.user = @founder
      redirect(url(:action => 'organisation_details'))
    else
      redirect(url(:action => 'founder'), :message => {:error => "There was a problem with your details: #{@founder.errors.full_messages.to_sentence}"})
    end
  end
  
  def organisation_details
    @organisation_name = Organisation.name
    @objectives = Organisation.objectives
    @assets = Organisation.assets || true
    render
  end
  
  def create_organisation_details
    organisation_name = Clause.get_current('organisation_name') || Clause.new(:name => 'organisation_name')
    organisation_name.text_value = params[:organisation_name]
    organisation_name.save
  
    objectives = Clause.get_current('objectives') || Clause.new(:name => 'objectives')
    objectives.text_value = params[:objectives]
    objectives.save
    
    assets = Clause.get_current('assets') || Clause.new(:name => 'assets')
    assets.boolean_value =  params[:assets] == '1'
    assets.save
    
    if params[:organisation_name].blank? || params[:objectives].blank?
        redirect(url(:action => 'organisation_details'), :message => {:error => "You must fill in the organisation name and objects."})
    else
      redirect(url(:action => 'members'))
    end
  end
  
  def members
    # Find the first fifteen members after the founding member,
    # creating new empty members as necessary.
    @members = Member.all
    @founder = @members.shift
    while @members.length < 15 do
      @members.push(Member.new)
    end
    render
  end
  
  def create_members
    params[:members].each_value do |member_params|
      if !member_params[:name].blank? && !member_params[:email].blank?
        if member_params[:id].blank?
          member = Member.new
          member.new_password!
        else
          member = Member.get!(member_params[:id])
        end
        member.name = member_params[:name]
        member.email = member_params[:email]
        member.save
      elsif !member_params[:id].blank?
        # We get here if the name and email fields have been cleared
        # for a memeber that's already been saved to the database.
        # Treat this as a deletion.
        Member.get!(member_params[:id]).destroy
      end
    end
    redirect(url(:action => 'voting_settings'))
  end
  
  def voting_settings
    @voting_period = Clause.get_integer(:voting_period) or 259200
    @general_voting_system = Clause.get_text(:general_voting_system) or 'RelativeMajority'
    @membership_voting_system = Clause.get_text(:membership_voting_system) or 'AbsoluteTwoThirdsMajority'
    @constitution_voting_system = Clause.get_text(:constitution_voting_system) or 'AbsoluteTwoThirdsMajority'
    render
  end
  
  def create_voting_settings
    voting_period = Clause.get_current('voting_period') || Clause.new(:name => 'voting_period')
    voting_period.integer_value = params[:voting_period]
    voting_period.save
    
    general_voting_system = Clause.get_current('general_voting_system') || Clause.new(:name => 'general_voting_system')
    general_voting_system.text_value = params[:general_voting_system]
    general_voting_system.save
    
    membership_voting_system = Clause.get_current('membership_voting_system') || Clause.new(:name => 'membership_voting_system')
    membership_voting_system.text_value = params[:membership_voting_system]
    membership_voting_system.save
    
    constitution_voting_system = Clause.get_current('constitution_voting_system') || Clause.new(:name => 'constitution_voting_system')
    constitution_voting_system.text_value = params[:constitution_voting_system]
    constitution_voting_system.save
    
    redirect(url(:action => 'preview_constitution'))
  end
  
  def preview_constitution
    prepare_constitution_view
    render
  end
  
  def founding_meeting_details
    @founding_meeting_date = Clause.get_text('founding_meeting_date')
    @founding_meeting_time = Clause.get_text('founding_meeting_time')
    @founding_meeting_location = Clause.get_text('founding_meeting_location')
    render
  end
  
  def create_founding_meeting_details
    founding_meeting_date = Clause.get_current('founding_meeting_date') || Clause.new(:name => 'founding_meeting_date')
    founding_meeting_date.text_value = params[:date]
    founding_meeting_date.save
  
    founding_meeting_time = Clause.get_current('founding_meeting_time') || Clause.new(:name => 'founding_meeting_time')
    founding_meeting_time.text_value = params[:time]
    founding_meeting_time.save
  
    founding_meeting_location = Clause.get_current('founding_meeting_location') || Clause.new(:name => 'founding_meeting_location')
    founding_meeting_location.text_value = params[:location]
    founding_meeting_location.save
    
    if params[:date].blank? || params[:time].blank? || params[:location].blank?
      redirect(url(:action => 'founding_meeting_details'), :message => {:error => "You must fill in a date, time and location for the founding meeting."})
    else
      redirect(url(:action => 'preview_agenda'))
    end
  end
  
  def preview_agenda
    @organisation_name = Organisation.name
    @founding_meeting_location = Clause.get_text('founding_meeting_location')
    @founding_meeting_date = Clause.get_text('founding_meeting_date')
    @founding_meeting_time = Clause.get_text('founding_meeting_time')
    
    @members = Member.all.active
    
    render
  end
    
  # Sends the constitution and agenda to founding members,
  # and moves the organisation to 'pending' state.
  def confirm_agenda
    organisation_state = Clause.get_current('organisation_state') || Clause.new(:name => 'organisation_state')
    organisation_state.text_value = 'pending'
    organisation_state.save!
    
    # Send emails with founding meeting agenda
    Member.all.each do |member|
      async_job :send_agenda_email, member
    end
    
    redirect(url(:action => 'founding_meeting'))
  end
  
  # PENDING STATE  
  
  # Form to confirm that the founding meeting happened,
  # and select which founding members voted in favour.
  def founding_meeting
    @organisation_name = Organisation.name
    @founding_member = Member.first
    @other_members = Member.all; @other_members.shift
    
    render
  end
  
  # Remove any founding members that did not vote in favour,
  # and move organisation to 'active' state.
  def confirm_founding_meeting
    other_members = Member.all.to_a[1..-1]
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
    
    organisation_state = Clause.get_current('organisation_state')
    organisation_state.text_value = "active"
    organisation_state.save
    
    #now, send out emails to confirm creation of all members
    other_members.each do |m|
      Merb.logger.info("sending welcome message to #{m}")
      m.send_welcome
    end
      
    redirect(url(:controller => 'one_click', :action => 'control_centre'))
  end
  
  # Moves the organisation back from 'pending' state, to
  # allow editing of org details.
  def restart_induction
    Clause.get_current('founding_meeting_date').destroy
    Clause.get_current('founding_meeting_time').destroy
    Clause.get_current('founding_meeting_location').destroy
    
    Clause.get_current('organisation_state').destroy
    
    redirect(url(:action => 'organisation_details'))
  end
  
private
  def check_active_organisation
    if Organisation.active?
      if Organisation.has_founding_member?
        throw :halt, redirect(url(:controller => 'one_click', :action => 'control_centre'))
      else
        Organisation.under_construction!
        throw :halt, "ERROR: organisation marked as active but no members present - reset"
      end
    end
  end
  
  def ensure_organisation_under_construction
    throw :halt, redirect(url(:action => 'founding_meeting')) unless Organisation.under_construction?
  end
  
  def ensure_organisation_pending
    throw :halt, redirect(url(:action => 'founder')) unless Organisation.pending?
  end

public
  
  def self.send_agenda_email(member)
    organisation_name = Organisation.name
    founding_meeting_location = Clause.get_text('founding_meeting_location')
    founding_meeting_date = Clause.get_text('founding_meeting_date')
    founding_meeting_time = Clause.get_text('founding_meeting_time')
    founding_member_name = Member.first.name
    members = Member.all
    
    send_mail(InductionMailer, :notify_agenda,
      {:to => member.email, :from => 'info@oneclickor.gs', :subject => "Agenda for '#{organisation_name}' founding meeting"},
      {
        :member => member,
        :organisation_name => organisation_name,
        :founding_meeting_location => founding_meeting_location,
        :founding_meeting_date => founding_meeting_date,
        :founding_meeting_time => founding_meeting_time,
        :founding_member_name => founding_member_name,
        :members => members
      }
    )
  end
end
