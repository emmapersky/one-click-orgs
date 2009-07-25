class EjectMemberProposal < Proposal
  def enact!
    raise "Can not enact a proposal which has not passed" unless passed?
    params = YAML.JSON(self.parameters)
    member = Member.get(params['id'])
    member.destroy
  end
  
  def voting_system
    Constitution.voting_system(:membership)
  end
end