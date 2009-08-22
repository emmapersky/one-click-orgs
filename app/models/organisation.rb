class Organisation
  
  def self.has_founding_member?
    Member.count > 0
  end
  
  def self.under_construction?
    Clause.get_current('organisation_state').nil?
  end

  def self.pending?
    Clause.get_current('organisation_state') && Clause.get_current('organisation_state').text_value == 'pending'
  end
    
  def self.active?
    Clause.get_current('organisation_state') && Clause.get_current('organisation_state').text_value == 'active'
  end
  
  def self.under_construction!
    clause = Clause.get_current('organisation_state')
    clause && clause.destroy    
  end
end