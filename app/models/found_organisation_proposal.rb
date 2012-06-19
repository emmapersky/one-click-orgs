# Remove any founding members that did not vote in favour,
# and move organisation to 'active' state.
class FoundOrganisationProposal < Proposal
  
  def reject!(params)
    organisation.failed!
    organisation.save
    # TODO email all founding members: failed to agree to found org
  end
  
  def enact!(params)
    # initial members are all founding members that didn't vote "no" (including 
    # members who abstained.)
    confirmed_member_ids = []
    Vote.all.each do |v|
      confirmed_member_ids << v.member_id unless v.for == false
    end
    
    organisation.members.each do |member|
      if confirmed_member_ids.include?(member.id)
        member.member_class = organisation.member_classes.find_by_name('Member')
        member.inducted!
        member.save!
      else
        member.destroy 
      end
    end
    
    organisation.active!
    organisation.save
    
    # send out emails to announce org creation to all remaining members
    # TODO send separate email to members who voted "no"
    organisation.members.each do |m|
      # TODO replace this with a tailored email message about the successful foundation
      # of the org
      # TODO Don't need to reset their passwords at this point
      Rails.logger.info("sending welcome message to #{m}")
      m.new_password!
      m.save
      m.send_welcome
    end
  end
  
  # TODO Need a special voting system for FoundOrganisationProposal
  # which simply requires three or more yes votes
  def voting_system
    organisation.constitution.voting_system(:constitution)
  end
end
