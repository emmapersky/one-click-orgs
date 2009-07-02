class ChangeVotingSystemProposal < Proposal
  def enact!
    raise "Can not enact a proposal which has not passed" unless passed?    
    params = YAML.JSON(self.parameters)
    Constitution.set_voting_system(params['type'], params['proposed_system'])
  end
  
  def get_voting_system
    Constitution.get_constitution_voting_system
  end
end
