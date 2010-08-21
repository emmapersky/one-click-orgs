class ChangeVotingSystemProposal < Proposal
  def enact!(params)
    organisation.constitution.change_voting_system(params['type'], params['proposed_system'])
  end
  
  def voting_system
    organisation.constitution.voting_system(:constitution)
  end
end
