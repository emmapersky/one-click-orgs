# TODO Overhaul this

def stub_setup!
  Setting[:base_domain] ||= "oneclickorgs.com"
end

def default_member_class
  stub_organisation!
  @default_member_class = @organisation.member_classes.where(:name => "Clown").first || 
    @organisation.member_classes.create!(:name => "Clown")
end

def default_user
  stub_constitution!
  stub_organisation!
    
  @default_user = @organisation.members.where(:email => "krusty@clown.com").first || 
    @organisation.members.create(:email => "krusty@clown.com",
                 :first_name => "Krusty the",
                 :last_name => "clown",
                 :password => "password",
                 :password_confirmation => "password",
                 :inducted_at => (Time.now.utc - 1.day),
                 :member_class => default_member_class) or raise "can't create user"
end

def stub_constitution!
  stub_organisation!
  @organisation.clauses.set_integer(:voting_period, 3 * 86400)
end

def stub_voting_systems!
  stub_constitution!
  @organisation.clauses.set_text(:general_voting_system, 'RelativeMajority')
  @organisation.clauses.set_text(:constitution_voting_system, 'RelativeMajority')
  @organisation.clauses.set_text(:membership_voting_system, 'RelativeMajority')
end

def stub_organisation!(active=true, name='test', stub_host_lookup=true, new_organisation=false)
  stub_setup!
  if new_organisation || !@organisation
    @organisation = Organisation.make(:subdomain => name)
    
    # TODO remove this; we don't use this clause anymore
    @organisation.clauses.set_text(:domain, "#{name}.oneclickorgs.com")
    
    @organisation.clauses.set_text(:organisation_name, name)
  
    organisation_is_active if active
  
    if stub_host_lookup
      Organisation.stub!(:find_by_host).and_return(@organisation)
    end
  end
  @organisation
end

def login
  @user = default_user
  post "/member_session", {:email => @user.email, :password => "password"}
  @user
end

def set_permission(user, perm, value)
  user.member_class.set_permission(perm, value)
  user.member_class.save
end

def passed_proposal(p, args={})
  p.stub!(:passed?).and_return(true)
  lambda { p.enact!(args) }
end

def organisation_is_pending
  stub_organisation!(false) unless @organisation
  @organisation.clauses.set_text('organisation_state', "pending")
end

def organisation_is_active
  stub_organisation!(false) unless @organisation
  @organisation.clauses.set_text('organisation_state', "active")
  @organisation.should be_active
end

def organisation_is_under_construction
  stub_organisation!(false) unless @organisation
  clause = @organisation.clauses.get_current('organisation_state')
  clause.destroy if clause
end
