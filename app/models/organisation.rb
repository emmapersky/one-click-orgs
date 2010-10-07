class Organisation < ActiveRecord::Base
  has_many :clauses
  has_many :members
  
  has_many :proposals
  
  # Need to add the subclasses individually so that we can do things like:
  #   co.add_member_proposals.create(...)
  # to create a properly-scoped AddMemberProposal.
  has_many :add_member_proposals
  has_many :change_boolean_proposals
  has_many :change_text_proposals
  has_many :change_voting_period_proposals
  has_many :change_voting_system_proposals
  has_many :eject_member_proposals
  
  has_many :decisions, :through => :proposals
  
  has_many :member_classes
  
  validates_uniqueness_of :subdomain
  
  after_create :create_default_member_classes
  
  # Given a full hostname, e.g. "myorganisation.oneclickorgs.com",
  # and assuming the installation's base domain is "oneclickorgs.com",
  # returns the organisation corresponding to the subdomain
  # "myorganisation".
  def self.find_by_host(host)
    subdomain = host.sub(Regexp.new("\.#{Setting[:base_domain]}$"), '')
    where(:subdomain => subdomain).first
  end
  
  def organisation_name
    clauses.get_text('organisation_name')
  end
  
  def objectives
    clauses.get_text('objectives')
  end
  
  def assets
    clauses.get_boolean('assets')
  end
  
  # Returns the base URL for this instance of OCO.
  # Pass the :only_host => true option to just get the host name.
  def domain(options={})
    raw_domain = host
    if options[:only_host]
      raw_domain
    else
      "http://#{raw_domain}"
    end
  end
  
  def host
    [subdomain, Setting[:base_domain]].join('.')
  end
  
  def has_founding_member?
    members.count > 0
  end
  
  def under_construction?
    clauses.get_text('organisation_state').nil?
  end

  def pending?
    clauses.get_text('organisation_state') == 'pending'
  end
    
  def active?
    clauses.get_text('organisation_state') == 'active'
  end
  
  def under_construction!
    clause = clauses.get_current('organisation_state')
    clause && clause.destroy    
  end
  
  def constitution
    @constitution ||= Constitution.new(self)
  end
  
  def create_default_member_classes
    # Set up a simple organisation: all members are equal
    members = member_classes.find_or_create_by_name('Member')
    members.set_permission(:constitution_proposal, true)
    members.set_permission(:membership_proposal, true)
    members.set_permission(:freeform_proposal, true)
    members.set_permission(:vote, true)
  end
end
