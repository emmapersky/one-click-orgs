class ChangeVotingSystemProposal < Proposal

  def enact!(params)
    Constitution.change_voting_system(params['type'], params['proposed_system'])
  end
  
  def voting_system
    Constitution.voting_system(:constitution)
  end
end
