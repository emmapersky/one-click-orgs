require File.join(Rails.root, '/lib/periodic_proposal_closer')

# HACKTASTIC.
begin
  unless Delayed::Job.where(["handler LIKE ?", "%PeriodicProposalCloser%"]).count > 0
    Delayed::Job.enqueue(PeriodicProposalCloser.new)
  end
rescue
end
