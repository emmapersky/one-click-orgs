class DecisionMailer < OcoMailer

  def notify_new_decision(member, decision)
    default_url_options[:host] = member.organisation.domain(:only_host => true)

    @decision = decision
    @proposal = @decision.proposal
    @member = member

    raise ArgumentError, "need decision" unless @decision and @member
    raise ArgumentError, "decision has no attached propsoal" unless @proposal
    mail(:to => @member.email, :subject => "new one click decision")
  end
end
