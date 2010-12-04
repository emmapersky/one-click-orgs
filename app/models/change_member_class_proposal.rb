class ChangeMemberClassProposal < Proposal

  def allows_direct_edit?
    true
  end

  def enact!(params)
    member = organisation.members.find(params['id']) # TODO verify that this member still exists
    mc = organisation.member_classes.find(params['member_class_id']) # TODO verify that this member class still exists
    member.member_class = mc
    member.save
  end
  
  def voting_system
    organisation.constitution.voting_system(:membership)
  end
end
