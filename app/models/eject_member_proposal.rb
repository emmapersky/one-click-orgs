class EjectMemberProposal < Proposal
  def enact!(args={})
    raise "Can not enact a proposal which has not passed" unless passed?
    
    params = YAML.JSON(self.parameters)
    member = Member.get(params['id'])
    member.eject!
  end
  
  def voting_system
    Constitution.voting_system(:membership)
  end
end