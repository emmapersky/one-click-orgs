# Constitution is a convenience class that provides methods for getting and setting
# constitution-related aspects of an organisation.
# 
# Typically, you'll let your Organisation object set up the Constitution object
# for you, e.g.
# 
#   organisation.constitution.change_voting_system(:general, 'RelativeMajority')
class Constitution
  def initialize(organisation)
    @organisation = organisation
  end
  
  def organisation
    @organisation
  end
  
  # VOTING SYSTEMS
  
  def voting_system(type = :general)     
    clause = organisation.clauses.get_current("#{type}_voting_system") 
    raise ArgumentError, "invalid system: #{type}" unless clause && clause.text_value
    VotingSystems.get(clause.text_value)
  end
  
  def get_general_voting_system
    warn "[DEPRECATED] use voting_system(type) instead"
    voting_system :general
  end
  
  def get_membership_voting_system
    warn "[DEPRECATED] use voting_system(type) instead"
    voting_system :membership
  end
  
  def get_constitution_voting_system
    warn "[DEPRECATED] use voting_system(type) instead"    
    voting_system :constitution
  end
  
  def set_membership_voting_system(params={})
    warn "[DEPRECATED] use change_voting_system(type,params) instead"    
    change_voting_system(:membership, params)
  end
  
  def set_constitution_voting_system(params={})
    warn "[DEPRECATED] use change_voting_system(type,params) instead"    
    change_voting_system(:constitution, params)
  end
  
  def change_voting_system(type, new_system)
    raise ArgumentError, "system #{type} not found" unless ['general', 'membership', 'constitution'].include?(type.to_s)
    raise ArgumentError, "no previous voting system" unless organisation.clauses.exists?("#{type}_voting_system")
    raise ArgumentError, "invalid voting system: #{new_system}" unless VotingSystems.get(new_system)
    organisation.clauses.set_text("#{type}_voting_system", new_system)
  end
  
  # VOTING PERIOD
  
  def voting_period
    organisation.clauses.get_integer('voting_period')
  end
  
  def change_voting_period(new_period)
    raise ArgumentError, "invalid voting period #{new_period}" unless new_period > 0
    raise ArgumentError, "no previous voting period" unless organisation.clauses.exists?('voting_period')
    
    c = organisation.clauses.set_integer('voting_period', new_period)
  end
end
