class ResetPassword < Application
  skip_before :ensure_authenticated
  
  def index
    render
  end
  
  def reset(email)
    if m = Member.first(:email => email)      
        new_password = m.new_password!
        if m.save
          run_later do
            mail = Merb::Mailer.new(:to => m.email, :from => 'info@oneclickor.gs', :subject => 'Your password', :text => <<-END)
            Dear #{m.name || 'member'},

            your password has been reset to:
            #{new_password}

            Thanks

            oneclickor.gs
            END
            mail.deliver!          
          end
                
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
end