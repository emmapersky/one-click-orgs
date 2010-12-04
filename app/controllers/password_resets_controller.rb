class PasswordResetsController < ApplicationController
  skip_before_filter :ensure_authenticated
  
  def new
  end
  
  def create
    email = params[:email]
    if m = co.members.where(:email => email).first
      m.new_password_reset_code!
      MembersMailer.password_reset(m).deliver
      render(:action => :show)
    else
      redirect_to({:action=>:new}, :flash => { :error => "No such user with email: #{email}" })
    end
  end
  
  def edit
    @password_reset_code = params[:id]
    @member = Member.find_by_password_reset_code(@password_reset_code)
    
    unless @member
      render(:action => :not_found)
    end
  end
  
  def update
    @password_reset_code = params[:id]
    @member = Member.find_by_password_reset_code(@password_reset_code)
    @member.attributes = params[:member]
    if @member.save
      @member.clear_password_reset_code!
      self.current_user = @member
      flash[:notice] = "Your new password has been saved."
      redirect_to(root_path)
    else
      flash[:error] = "There was a problem with your new details."
      render(:action => :edit)
    end
  end
end
