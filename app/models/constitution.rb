class Constitution
  
  def self.get_organisation_name
    Clause.get_current("organisation_name").text_value
  end
  
  def self.get_general_voting_system
    voting_system(Clause.get_current('general_voting_system').text_value)
  end
  
  def self.get_membership_voting_system
    voting_system(Clause.get_current('membership_voting_system').text_value)
  end
  
  def self.set_membership_voting_system(params={})
    Clause.create(:name => 'membership_voting_system', :text_value => params['class_name'])
  end
  
  def self.get_constitution_voting_system
    voting_system(Clause.get_current('constitution_voting_system').text_value)
  end

  def self.set_constitution_voting_system(params={})
    Clause.create(:name => 'constitution_voting_system', :text_value => params['class_name'])
  end
  
  def self.set_voting_system(type, new_system)
    system = Clause.first(:name=>"#{type}_voting_system")
    raise ArgumentError, "system #{type} not found" unless system
    raise ArgumentError, "invalid voting system: #{new_system}" unless Constitution.voting_system(new_system)
    system.text_value = new_system
    system.save!
  end
  
  def self.get_voting_period
    Clause.get_current('voting_period').integer_value rescue 3 * 86400 # fixme
  end
  
  def self.voting_system(klass)
    raise ArgumentError, "empty argument" if klass.nil?
    
    begin
      VotingSystems.const_get(klass.to_s) 
    rescue NameError
      nil
    end
  end
end