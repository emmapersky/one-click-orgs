namespace :users do 
  desc "create default users"
  task :create => :merb_env do
#    DataMapper.auto_migrate!

    [['jan.berkel@gmail.com', 'Jan Berkel'],
    ['emma@trampolinesystems.com', 'Emma Persky'],
    ['charles@circus-foundation.org', 'Charles Armstrong'],
    ['martin@dekstop.de', 'Martin Dittus'],
    ['colintate@gmail.com', 'Colin Tate'],
    ].each do |(email, name)|
      Member.create!(:email=>email, :name=>name, :password=>'oneclick') unless Member.first(:email=>email)
    end
  end
end
