class AddMemberProposal < Proposal
  def enact!(params)
    organisation.members.create_member(params, true)
  end
  
  def voting_system
    organisation.constitution.voting_system(:membership)
  end
end
