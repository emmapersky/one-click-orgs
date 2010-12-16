class MembersMailer < OcoMailer
  def welcome_new_member(member)
    default_url_options[:host] = member.organisation.domain(:only_host => true)

    @member = member
    @organisation_name = member.organisation.organisation_name
    mail(:to => @member.email, :subject => "Your password", :from => "\"#{@organisation_name}\" <notifications@oneclickorgs.com>")
  end
  
  def password_reset(member)
    default_url_options[:host] = member.organisation.domain(:only_host => true)
    
    @member = member
    @organisation_name = member.organisation.organisation_name
    mail(:to => @member.email, :subject => "Your password", :from => "\"#{@organisation_name}\" <notifications@oneclickorgs.com")
  end
end
