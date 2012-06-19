# Represents a proposal to change one of the free-text fields
# in the constitution; e.g. the organisation name, or the
# organisation objectives.
class ChangeTextProposal < Proposal

  def allows_direct_edit?
    true
  end

  def enact!(params)
    organisation.clauses.set_text(params['name'], params['value'])
  end
  
  def voting_system
    organisation.constitution.voting_system(:constitution)
  end
  
  validates_each :parameters do |record, attribute, value|
    if Clause.get_text(record.parameters['name']) == record.parameters['value']
      record.errors.add :base, "Proposal does not change the current clause"
    end
  end
end
