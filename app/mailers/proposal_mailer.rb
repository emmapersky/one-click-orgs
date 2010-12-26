class ProposalMailer < OcoMailer

  def notify_creation(member, proposal)
    default_url_options[:host] = member.organisation.domain(:only_host => true)

    @member = member
    @proposal = proposal
    
    @organisation_name = member.organisation.name

    raise ArgumentError, "need member and proposal" unless @member and @proposal

    mail(:to => @member.email, :subject => "New proposal: #{@proposal.title}", :from => "\"#{@organisation_name}\" <notifications@oneclickorgs.com>")
  end
end
