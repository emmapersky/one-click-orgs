class MembersMailer < OcoMailer
  def welcome_new_member(member)
    default_url_options[:host] = member.organisation.domain(:only_host => true)

    @member = member
    @organisation_name = member.organisation.name
    mail(:to => @member.email, :subject => "Your password")
  end
  
  def password_reset(member)
    default_url_options[:host] = member.organisation.domain(:only_host => true)
    
    @member = member
    mail(:to => @member.email, :subject => "Your password")
  end
end
