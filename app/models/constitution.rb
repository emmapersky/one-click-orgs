class Constitution
  
  # VOTING SYSTEMS
  
  def self.voting_system(type = :general)     
    clause = Clause.get_current("#{type}_voting_system") 
    raise ArgumentError, "invalid system: #{type}" unless clause && clause.text_value
    VotingSystems.get(clause.text_value)
  end
  
  def self.get_general_voting_system
    warn "[DEPRECATED] use voting_system(type) instead"
    voting_system :general
  end
  
  def self.get_membership_voting_system
    warn "[DEPRECATED] use voting_system(type) instead"
    voting_system :membership
  end
  
  def self.get_constitution_voting_system
    warn "[DEPRECATED] use voting_system(type) instead"    
    voting_system :constitution
  end
  
  def self.set_membership_voting_system(params={})
    warn "[DEPRECATED] use change_voting_system(type,params) instead"    
    change_voting_system(:membership, params)
  end
  
  def self.set_constitution_voting_system(params={})
    warn "[DEPRECATED] use change_voting_system(type,params) instead"    
    change_voting_system(:constitution, params)
  end
  
  def self.change_voting_system(type, new_system)
    raise ArgumentError, "system #{type} not found" unless ['general', 'membership', 'constitution'].include?(type.to_s)
    raise ArgumentError, "no previous voting system" unless Clause.exists?("#{type}_voting_system")
    raise ArgumentError, "invalid voting system: #{new_system}" unless VotingSystems.get(new_system)
    Clause.set_text("#{type}_voting_system", new_system)
  end
  
  # VOTING PERIOD
  
  def self.voting_period
    Clause.get_integer('voting_period') rescue 3 * 86400 # fixme
  end
  
  def self.change_voting_period(new_period)
    raise ArgumentError, "invalid voting period #{new_period}" unless new_period > 0
    raise ArgumentError, "no previous voting period" unless Clause.exists?('voting_period')
    
    c = Clause.set_integer('voting_period', new_period)
    c.integer_value = new_period
    c.save!
  end
  
end
