class Constitution
  
  def self.organisation_name
    Clause.get_current("organisation_name").text_value
  end
  
  def self.voting_system(type = :general)     
    voting_system(Clause.get_current("#{type}_voting_system").text_value)
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
    warn "[DEPRECATED] use set_voting_system(type,params) instead"    
    set_voting_system(:membership, params)
  end
  
  def self.set_constitution_voting_system(params={})
    warn "[DEPRECATED] use set_voting_system(type,params) instead"    
    set_voting_system(:constitution, params)
  end
  
  def self.set_voting_system(type, new_system)
    system = Clause.first(:name=>"#{type}_voting_system")
    raise ArgumentError, "system #{type} not found" unless system
    raise ArgumentError, "invalid voting system: #{new_system}" unless VotingSystems.get(new_system)
    system.text_value = new_system
    system.save!
  end
  
  def self.voting_period
    Clause.get_current('voting_period').integer_value rescue 3 * 86400 # fixme
  end
  
end