# Represents a proposal to change one of the free-text fields
# in the constitution; e.g. the organisation name, or the
# organisation objectives.
class ChangeTextProposal < Proposal
  def enact!(params)
    organisation.clauses.set_text(params['name'], params['value'])
  end
  
  def voting_system
    organisation.constitution.voting_system(:constitution)
  end
end
