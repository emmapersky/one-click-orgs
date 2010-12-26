# Represents a proposal to change the voting period for propsosals.
class ChangeVotingPeriodProposal < Proposal

  def allows_direct_edit?
    true
  end

  def enact!(params)
    organisation.constitution.change_voting_period(params['new_voting_period'].to_i)
  end
end
