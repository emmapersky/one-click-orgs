def default_member_class
  @default_member_class = MemberClass.where(:name => "Clown").first || 
    MemberClass.create(:name => "Clown") or raise "can't create member class"
end

def default_user
  stub_constitution!
  stub_organisation!
    
  @default_user = Member.where(:email => "krusty@clown.com").first || 
    Member.create(:email => "krusty@clown.com",
                 :name => "Krusty the clown",
                 :password => "password",
                 :password_confirmation => "password",
                 :inducted_at => (Time.now.utc - 1.day),
                 :member_class => default_member_class) or raise "can't create user"
end

def stub_constitution!
  Constitution.stub!(:voting_period).and_return(3 * 86400)
end

def stub_voting_systems!
  Constitution.stub!(:voting_system).and_return(VotingSystems.get(:RelativeMajority))
end

def stub_organisation!
  organisation_is_active
  Organisation.stub!(:domain).and_return('http://test.com')
  Organisation.stub!(:organisation_name).and_return('test')
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
  Clause.set_text('organisation_state', "pending")
end

def organisation_is_active
  Clause.set_text('organisation_state', "active")
end

def organisation_is_under_construction
  clause = Clause.get_current('organisation_state')
  clause.destroy if clause
end
