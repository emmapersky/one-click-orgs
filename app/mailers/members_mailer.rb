class MembersMailer < ActionMailer::Base
  default :from => "info@oneclickor.gs"
  
  def welcome_new_member(member, password)
    @member = member
    @password = password
    @organisation_name = Organisation.organisation_name
    mail(:to => @member.email, :subject => "Your password")
  end
  
  def notify_new_password(member, new_password)
    @member = member
    @new_password = new_password
    mail(:to => @member.email, :subject => "Your password")
  end
end
