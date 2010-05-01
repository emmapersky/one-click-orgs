def stub_setup!
  Setting[:base_domain] = "oneclickorgs.com"
end

def default_user
  stub_constitution!
  stub_organisation!
    
  @default_user = @organisation.members.where(:email => "krusty@clown.com").first || 
    @organisation.members.create(
      :email => "krusty@clown.com",
      :name => "Krusty the clown",
      :password => "password",
      :password_confirmation => "password",
      :inducted => true) or raise "can't create user"
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

def stub_organisation!(active=true)
  stub_setup!
  @organisation ||= Organisation.make(:subdomain => 'test')
  @organisation.clauses.set_text(:domain, 'test.oneclickorgs.com')
  @organisation.clauses.set_text(:organisation_name, 'test')
  
  organisation_is_active if active
  
  Organisation.stub!(:find_by_host).and_return(@organisation)
end

def login
  @user = default_user
  post "/member_session", {:email => @user.email, :password => "password"}
  @user
end


def passed_proposal(p, args={})
  p.stub!(:passed?).and_return(true)
  lambda { p.enact!(args) }
end

def organisation_is_pending
  stub_organisation!(false)
  @organisation.clauses.set_text('organisation_state', "pending")
end

def organisation_is_active
  stub_organisation!(false)
  @organisation.clauses.set_text('organisation_state', "active")
end

def organisation_is_under_construction
  stub_organisation!(false)
  clause = @organisation.clauses.get_current('organisation_state')
  clause.destroy if clause
end
