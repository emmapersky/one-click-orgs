class Constitution
  
  def self.get_organisation_name
    "One Click Organisations"
  end
  
  def self.get_voting_system(klass)
    VotingSystem
  end
  
  def self.get_general_voting_system
    VotingSystem
  end
  
  def self.get_membership_voting_system
    Clause.get_current('membership_voting_system').text_value.constantize
  end
  
  def self.set_membership_voting_system(params={})
    Clause.create(:name => 'membership_voting_system', :text_value => params['class_name'])
  end
  
  def self.get_constitution_voting_system
    Clause.get_current('constitution_voting_system').text_value.constantize
  end

  def self.set_constitution_voting_system(params={})
    Clause.create(:name => 'constitutionp_voting_system', :text_value => params['class_name'])
  end
  
  def self.get_voting_period
    3.days
  end
end

class VotingSystem
  def self.passed?(params={})
    true
  end
end

class RelativeMajority < VotingSystem
  
end