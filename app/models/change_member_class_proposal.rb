class ChangeMemberClassProposal < Proposal
  def enact!(params)
    member = Member.find(params['id']) # TODO verify that this member still exists
    mc = MemberClass.find(params['member_class_id']) # TODO verify that this member class still exists
    member.member_class = mc
    member.save
  end
  
  def voting_system
    Constitution.voting_system(:membership)
  end
end
