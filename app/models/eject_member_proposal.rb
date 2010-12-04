class EjectMemberProposal < Proposal

  def allows_direct_edit?
    true
  end

  def enact!(params)
    raise "Can not enact a proposal which has not passed" unless passed?
    member = organisation.members.find(params['id'])
    if organisation.pending?
      # Special case: org in pending state
      member.destroy
    else
      member.eject!
    end
  end
  
  def voting_system
    organisation.constitution.voting_system(:membership)
  end
end
