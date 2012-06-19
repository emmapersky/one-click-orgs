class AddMemberProposal < Proposal
  validate :member_must_not_already_be_active
  def member_must_not_already_be_active
    errors.add(:base, "A member with this email address already exists") if organisation.members.active.find_by_email(parameters['email'])
  end
  
  def allows_direct_edit?
    true
  end

  def enact!(params)
    @existing_member = organisation.members.inactive.find_by_email(params['email'])
    if @existing_member
      @existing_member.reactivate!
    else
      organisation.members.create_member(params, true)
    end
  end
  
  def voting_system
    organisation.constitution.voting_system(:membership)
  end
end
