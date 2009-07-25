class Constitution
  
  # FREE TEXT FIELDS
  
  def self.organisation_name
    Clause.get_current("organisation_name").text_value
  end
  
  def self.objectives
    Clause.get_current('objectives').text_value
  end
  
  def self.domain
    Clause.get_current('domain').text_value
  end
  
  def self.set_text(name, value)
    name = name.to_s
    case name
    when 'organisation_name'
      Clause.create!(:name => 'organisation_name', :text_value => value)
    when 'objectives'
      Clause.create!(:name => 'objectives', :text_value => value)
    when 'domain'
      Clause.create!(:name => 'domain', :text_value => value)
    else
      raise ArgumentError, "invalid text field name: #{name}"
    end
  end
  
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
    system = Clause.first(:name=>"#{type}_voting_system")
    raise ArgumentError, "system #{type} not found" unless system
    raise ArgumentError, "invalid voting system: #{new_system}" unless VotingSystems.get(new_system)
    system.text_value = new_system
    system.save!
  end
  
  # VOTING PERIOD
  
  def self.voting_period
    Clause.get_current('voting_period').integer_value rescue 3 * 86400 # fixme
  end
  
end