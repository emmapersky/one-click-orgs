class PeriodicProposalCloser
  def perform
    Proposal.close_proposals
    Delayed::Job.enqueue(PeriodicProposalCloser.new, 0, 60.seconds.from_now)
  end
end
