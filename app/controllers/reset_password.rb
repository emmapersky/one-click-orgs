class ResetPassword < Application
  skip_before :ensure_authenticated
  
  def index
    render
  end
  
  def reset(email)
    if m = Member.first(:email => email)
      #run_later do
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        new_password = ""
        1.upto(8) { new_password << chars[rand(chars.size-1)] }

        m.password = new_password
        m.save!
        mail = Merb::Mailer.new(:to => m.email, :from => 'info@oneclickor.gs', :subject => 'Your password', :text => <<-END)
        Dear #{m.name || 'member'},

        your password has been reset to:
        #{new_password}

        Thanks

        oneclickor.gs
        END
        mail.deliver!
        Merb.logger.debug("reset password for #{email} to '#{new_password}'")
                
      #end
      redirect url(:action=>:index), :message => { :notice => "New password was sent to #{email}" }
    else
      redirect url(:action=>:index), :message => { :error => "No such user with email: #{email}" }
    end
  end
end