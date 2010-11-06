class MembersMailer < OcoMailer
  def welcome_new_member(member, password)
    default_url_options[:host] = member.organisation.domain(:only_host => true)

    @member = member
    @password = password
    @organisation_name = member.organisation.organisation_name
    mail(:to => @member.email, :subject => "Your password")
  end

  def notify_new_password(member, new_password)
    default_url_options[:host] = member.organisation.domain(:only_host => true)

    @member = member
    @new_password = new_password
    mail(:to => @member.email, :subject => "Your password")
  end
end
