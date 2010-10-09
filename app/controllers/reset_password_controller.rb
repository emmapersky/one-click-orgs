class ResetPasswordController < ApplicationController
  skip_before_filter :ensure_authenticated
  
  def index
  end
  
  def reset
    email = params[:email]
    if m = co.members.where(:email => email).first
        new_password = m.new_password!
        if m.save
          ResetPasswordController.send_later(:do_reset_email, m.id, new_password)
          
          Rails.logger.debug("reset password for #{email} to '#{new_password}'")
          @email = email
          render(:action => :done)
        else
          Rails.logger.debug("error resetting password: #{m.errors.inspect}")
          redirect_to({:action=>:index}, :flash => { :error => "error resetting password: #{m.errors.inspect}" })                
        end

    else
      redirect_to({:action=>:index}, :flash => { :error => "No such user with email: #{email}" })
    end
  end
  
  def self.do_reset_email(member_id, new_password)
    member = Member.find(member_id)
    MembersMailer.notify_new_password(member, new_password).deliver
  end
end
