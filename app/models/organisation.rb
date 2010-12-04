class Organisation < ActiveRecord::Base
  has_many :clauses
  has_many :members
  
  has_many :found_organisation_proposals
  
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
  
  validates_presence_of :name, :objectives
  validates_uniqueness_of :subdomain
  
  after_create :create_default_member_classes
  after_create :set_default_voting_systems

  # Given a full hostname, e.g. "myorganisation.oneclickorgs.com",
  # and assuming the installation's base domain is "oneclickorgs.com",
  # returns the organisation corresponding to the subdomain
  # "myorganisation".
  def self.find_by_host(host)
    subdomain = host.sub(Regexp.new("\.#{Setting[:base_domain]}$"), '')
    where(:subdomain => subdomain).first
  end
  
  def name
    @name ||= clauses.get_text('organisation_name')
  end
  
  def name=(name)
    clauses.build(:name => 'organisation_name', :text_value => name)
    @name = name
  end
  
  def objectives
    @objectives ||= clauses.get_text('organisation_objectives')
  end
  
  def objectives=(objectives)
    clauses.build(:name => 'organisation_objectives', :text_value => objectives)
    @objectives = objectives
  end
  
  def assets
    @assets ||= clauses.get_boolean('assets')
  end
  
  def assets=(assets)
    clauses.build(:name => 'assets', :boolean_value => assets)
    @assets = assets
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
    subdomain ? [subdomain, Setting[:base_domain]].join('.') : Setting[:base_domain]
  end
  
  def has_founding_member?
    members.count > 0
  end
  
  def under_construction?
    clauses.get_text('organisation_state').nil?
  end
  
  def under_construction!
    clause = clauses.get_current('organisation_state')
    clause && clause.destroy    
  end

  def pending?
    clauses.get_text('organisation_state') == 'pending'
  end
    
  def pending!
    #clauses.set_text('organisation_state', 'pending')
    clauses.build(:name => 'organisation_state', :text_value => 'pending')
  end
    
  def proposed?
    clauses.get_text('organisation_state') == 'proposed'
  end
    
  def proposed!
    #clauses.set_text('organisation_state', 'proposed')
    clauses.build(:name => 'organisation_state', :text_value => 'proposed')
  end
    
  def failed?
    clauses.get_text('organisation_state') == 'failed'
  end
    
  def failed!
    #clauses.set_text('organisation_state', 'failed')
    clauses.build(:name => 'organisation_state', :text_value => 'failed')
  end
    
  def active?
    clauses.get_text('organisation_state') == 'active'
  end
  
  def active!
    #clauses.get_text('organisation_state', 'active')
    clauses.build(:name => 'organisation_state', :text_value => 'active')
  end
  
  def constitution
    @constitution ||= Constitution.new(self)
  end
  
  def default_member_class
    member_classes.first
  end
  
  def create_default_member_classes
    members = member_classes.find_or_create_by_name('Member')
    members.set_permission(:constitution_proposal, true)
    members.set_permission(:membership_proposal, true)
    members.set_permission(:freeform_proposal, true)
    members.set_permission(:vote, true)
    members.save
    
    founder = member_classes.find_or_create_by_name('Founder')
    founder.set_permission(:direct_edit, true)
    founder.set_permission(:constitution_proposal, true)
    founder.set_permission(:membership_proposal, true)
    founder.set_permission(:freeform_proposal, true)
    founder.set_permission(:found_organisation_proposal, true)
    founder.set_permission(:vote, true)
    founder.save

    founding_member = member_classes.find_or_create_by_name('Founding Member')
    founding_member.set_permission(:direct_edit, false)
    founding_member.set_permission(:constitution_proposal, false)
    founding_member.set_permission(:membership_proposal, false)
    founding_member.set_permission(:freeform_proposal, false)
    founding_member.set_permission(:found_organisation_proposal, false)
    founding_member.set_permission(:vote, true)
    founding_member.save
  end

  def set_default_voting_systems
    constitution.set_voting_system(:general, 'RelativeMajority')
    constitution.set_voting_system(:membership, 'AbsoluteTwoThirdsMajority')
    constitution.set_voting_system(:constitution, 'AbsoluteTwoThirdsMajority')
    constitution.set_voting_period(259200)
  end

end
