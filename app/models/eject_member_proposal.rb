class EjectMemberProposal < Proposal
  def enact!(args={})
    raise "Can not enact a proposal which has not passed" unless passed?
    
    params = ActiveSupport::JSON.decode(self.parameters)
    member = organisation.members.find(params['id'])
    member.eject!
  end
  
  def voting_system
    organisation.constitution.voting_system(:membership)
  end
end