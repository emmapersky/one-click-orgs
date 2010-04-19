class Organisation
  def self.organisation_name
    Clause.get_text('organisation_name')
  end
  
  def self.objectives
    Clause.get_text('objectives')
  end
  
  def self.assets
    Clause.get_boolean('assets')
  end
  
  # Returns the base URL for this instance of OCO.
  # Pass the :only_host => true option to just get the host name.
  def self.domain(options={})
    raw_domain = Clause.get_text('domain')
    if options[:only_host]
      raw_domain.gsub(%r{^.*?://}, '').gsub(%r{/$}, '')
    else
      raw_domain
    end
  end
  
  def self.has_founding_member?
    Member.count > 0
  end
  
  def self.under_construction?
    Clause.get_text('organisation_state').nil?
  end

  def self.pending?
    Clause.get_text('organisation_state') == 'pending'
  end
    
  def self.active?
    Clause.get_text('organisation_state') == 'active'
  end
  
  def self.under_construction!
    clause = Clause.get_current('organisation_state')
    clause && clause.destroy    
  end
end
