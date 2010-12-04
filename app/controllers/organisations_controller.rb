class OrganisationsController < ApplicationController
  skip_before_filter :ensure_organisation_exists
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_member_active
  #skip_before_filter :ensure_organisation_active
  #skip_before_filter :ensure_member_inducted
  
  before_filter :ensure_not_single_organisation_mode
  
  layout "setup"
  
  public
 
  def new
    @organisation = Organisation.new
    @founder = @organisation.members.first || @organisation.members.new
    #@single_organisation_mode = Setting[:single_organisation_mode]
  end
  
  def create
    @organisation = Organisation.new(params[:organisation])
    @founder = Member.new(params[:founder])
    
    errors = []
    
    # validate
    if !@founder.valid?
      errors << "Please complete your account details: #{@founder.errors.full_messages.to_sentence}."
    end
    if @founder.password != params[:founder][:password_confirmation]
      errors << "Your password and password confirmation do no match."
    end
    if !@organisation.valid?
      errors << "Please complete the details of your organisation: #{@organisation.errors.full_messages.to_sentence}."
    end   

    # validation succeeded -> store
    if errors.size == 0
      @organisation.members << @founder
      @organisation.pending!
      if !@organisation.save
        errors << "Cannot create your organisation: #{@organisation.errors.full_messages.to_sentence}."
      end
      @founder.member_class = @organisation.member_classes.find_by_name('Founder')
      if !@founder.save
        errors << "Cannot create your account: #{@founder.errors.full_messages.to_sentence}."
      end
    end
    
    # display errors
    if errors.size > 0
      flash[:error] = errors.join("\n") # don't want to insert <br>s here
      render :template => 'organisations/new'
      return
    end

    # continue
    self.current_user = @founder # TODO: do we still need this?

    if Setting[:single_organisation_mode]
      redirect_to(:controller => 'one_click')
    else
      redirect_to(:host => @organisation.host, :controller => 'one_click')
    end
  end
end
