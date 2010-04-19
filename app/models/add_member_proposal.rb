class AddMemberProposal < Proposal
  def enact!(params)
    Member.create_member(params, true)
  end
  
  def voting_system
    Constitution.voting_system(:membership)
  end
end
