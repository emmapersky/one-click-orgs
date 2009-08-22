class Organisation
  def self.under_construction?
    Clause.get_current('organisation_state').nil?
  end

  def self.pending?
    Clause.get_current('organisation_state') && Clause.get_current('organisation_state').text_value == 'pending'
  end
    
  def self.active?
    Clause.get_current('organisation_state') && Clause.get_current('organisation_state').text_value == 'active'
  end
end