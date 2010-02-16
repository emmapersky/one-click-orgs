class ResetPasswordController < Application
  # include AsyncJobs
  
  skip_before_filter :ensure_authenticated
  
  def index
  end
  
  def reset
    email = params[:email]
    if m = Member.where(:email => email).first
        new_password = m.new_password!
        if m.save
          # TODO Convert to new background job system
          async_job :do_reset_email, m.id, new_password
          
          Rails.logger.debug("reset password for #{email} to '#{new_password}'")
          redirect_to {:action=>:index}, :flash => { :notice => "New password was sent to #{email}" }                
        else
          Rails.logger.debug("error resetting password: #{m.errors.inspect}")
          redirect_to {:action=>:index}, :flash => { :error => "error resetting password: #{m.errors.inspect}" }                
        end

    else
      redirect_to {:action=>:index}, :flash => { :error => "No such user with email: #{email}" }
    end
  end
  
  # TODO Convert to ActionMailer syntax
  def self.do_reset_email(member_id, new_password)
    member = Member.get(member_id)
    send_mail(MembersMailer, :notify_new_password,
      {:to => member.email, :from => 'info@oneclickor.gs', :subject => 'Your password'},
      {:member => member, :new_password => new_password}
    )
  end
end