class AddMemberProposal < Proposal
  def enact!(params)
    member = Member.create_member(params)
  end
  
  def voting_system
    Constitution.voting_system(:membership)
  end
end