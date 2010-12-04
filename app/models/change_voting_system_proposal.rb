class ChangeVotingSystemProposal < Proposal

  def allows_direct_edit?
    true
  end

  def enact!(params)
    organisation.constitution.change_voting_system(params['type'], params['proposed_system'])
  end
  
  def voting_system
    organisation.constitution.voting_system(:constitution)
  end
end
