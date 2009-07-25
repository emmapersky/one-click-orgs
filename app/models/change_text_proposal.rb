# Represents a proposal to change one of the free-text fields
# in the constitution; e.g. the organisation name, or the
# organisation objectives.
class ChangeTextProposal < Proposal
  def enact!
    raise "Can not enact a proposal which has not passed" unless passed?    
    params = YAML.JSON(self.parameters)
    Constitution.set_text(params['name'], params['value'])
  end
end
