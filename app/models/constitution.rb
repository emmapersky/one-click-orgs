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
  
  def set_voting_system(type, new_system)
    raise ArgumentError, "system #{type} not found" unless ['general', 'membership', 'constitution'].include?(type.to_s)
    raise ArgumentError, "invalid voting system: #{new_system}" unless VotingSystems.get(new_system)
    organisation.clauses.set_text("#{type}_voting_system", new_system)
  end
  
  def change_voting_system(type, new_system)
    raise ArgumentError, "no previous voting system" unless organisation.clauses.exists?("#{type}_voting_system")
    set_voting_system(type, new_system)
  end
  
  # VOTING PERIOD
  
  def voting_period
    organisation.clauses.get_integer('voting_period')
  end
  
  def set_voting_period(new_period)
    raise ArgumentError, "invalid voting period #{new_period}" unless new_period > 0
    organisation.clauses.set_integer('voting_period', new_period)
  end

  def change_voting_period(new_period)
    raise ArgumentError, "no previous voting period" unless organisation.clauses.exists?('voting_period')
    set_voting_period(new_period)
  end
end
