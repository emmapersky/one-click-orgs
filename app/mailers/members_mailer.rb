class MembersMailer < Merb::MailController

  def welcome_new_member
    # use params[] passed to this controller to get data
    # read more at http://wiki.merbivore.com/pages/mailers
    @member = params[:member]
    @password = params[:password]
    render_mail
  end
  
  def notify_new_password
    @member = params[:member]
    @new_password = params[:new_password]
    render_mail
  end
  
end
