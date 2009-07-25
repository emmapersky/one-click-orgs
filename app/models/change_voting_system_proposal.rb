class ChangeVotingSystemProposal < Proposal
  def enact!
    raise "Can not enact a proposal which has not passed" unless passed?    
    params = YAML.JSON(self.parameters)
    Constitution.change_voting_system(params['type'], params['proposed_system'])
  end
  
  def voting_system
    Constitution.voting_system(:constitution)
  end
end
