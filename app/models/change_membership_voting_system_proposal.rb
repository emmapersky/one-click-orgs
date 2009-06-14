class ChangeMembershipVotingSystemProposal < Proposal
  def enact!
    raise "Can not enact a proposal which has not passed" unless passed?
    params = YAML.JSON(self.parameters)
    Consitution.set_membership_voting_system(params)
  end
  
  def get_voting_system
    Consitution.get_constitution_voting_system
  end
end