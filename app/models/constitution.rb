class Constitution
  
  def self.get_organisation_name
    Clause.get_current("organisation_name").text_value
  end
  
  def self.get_general_voting_system
    voting_system('RelativeMajority')
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
    Clause.create(:name => 'constitutionp_voting_system', :text_value => params['class_name'])
  end
  
  def self.get_voting_period
    Clause.get_current('voting_period').integer_value
  end
  
  def self.voting_system(klass)
    VotingSystems.const_get(klass)
  end
end