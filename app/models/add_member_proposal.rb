class AddMemberProposal < Proposal
  def enact!
    raise "Can not enact a proposal which has not passed" unless passed?
    params = YAML.JSON(self.parameters)
    member = Member.create_member(params)
  end
  
  def get_voting_system
    Constitution.get_membership_voting_system
  end
end