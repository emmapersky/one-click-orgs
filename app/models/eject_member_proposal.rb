class EjectMemberProposal < Proposal
  def enact!(args={})
    raise "Can not enact a proposal which has not passed" unless passed?
    
    params = JSON.parse(self.parameters)
    member = Member.find(params['id'])
    member.eject!
  end
  
  def voting_system
    Constitution.voting_system(:membership)
  end
end