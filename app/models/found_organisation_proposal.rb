# Remove any founding members that did not vote in favour,
# and move organisation to 'active' state.
class FoundOrganisationProposal < Proposal
  def enact!(params)
    confirmed_member_ids = if params['members'].respond_to?(:keys)
      params['members'].keys.map(&:to_i)
    else
      []
    end
    
    co.members.each do |member|
      # TODO send separate email to members who voted "no"
      member.destroy unless confirmed_member_ids.include?(member.id)
    end
    
    organisation_state = co.clauses.get_current('organisation_state')
    organisation_state.text_value = "active"
    organisation_state.save!
    
    # send out emails to announce org creation to all remaining members
    co.members.each do |m|
      Rails.logger.info("sending welcome message to #{m}")
      m.new_password!
      m.save
      m.send_welcome
    end
  end
  
  def voting_system
    organisation.constitution.voting_system(:constitution)
  end
end
