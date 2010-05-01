# Represents a proposal to change one of the boolean fields
# in the constitution; e.g. the assets-holding
class ChangeBooleanProposal < Proposal
  def enact!(params)
    organisation.clauses.set_boolean(params['name'], params['value'])
  end
  
  def voting_system
    organisation.constitution.voting_system(:constitution)
  end
end
