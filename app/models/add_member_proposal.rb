class AddMemberProposal < Proposal
  validate :member_must_not_already_exist
  def member_must_not_already_exist
    errors.add(:base, "A member with this email address already exists") if organisation.members.find_by_email(parameters['email'])
  end
  
  def enact!(params)
    organisation.members.create_member(params, true)
  end
  
  def voting_system
    organisation.constitution.voting_system(:membership)
  end
end
