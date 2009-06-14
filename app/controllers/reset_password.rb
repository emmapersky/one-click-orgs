class ResetPassword < Application
  include AsyncJobs
  
  skip_before :ensure_authenticated
  
  def index
    render
  end
  
  def reset(email)
    if m = Member.first(:email => email)      
        new_password = m.new_password!
        if m.save
          async_job :do_reset_email, m.id, new_password
          
          Merb.logger.debug("reset password for #{email} to '#{new_password}'")
          redirect url(:action=>:index), :message => { :notice => "New password was sent to #{email}" }                
        else
          Merb.logger.debug("error resetting password: #{m.errors.inspect}")
          redirect url(:action=>:index), :message => { :error => "error resetting password: #{m.errors.inspect}" }                
        end

    else
      redirect url(:action=>:index), :message => { :error => "No such user with email: #{email}" }
    end
  end
  
  def self.do_reset_email(member_id, new_password)
    member = Member.get(member_id)
    send_mail(MembersMailer, :notify_new_password,
      {:to => member.email, :from => 'info@oneclickor.gs', :subject => 'Your password'},
      {:member => member, :new_password => new_password}
    )
  end
end