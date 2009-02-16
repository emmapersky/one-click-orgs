namespace :users do 
  desc "create default users"
  task :create => :merb_env do

    DataMapper.auto_migrate!

    [['jan@trampolinesystems.com', 'Jan Berkel'],
    ['emma@trampolinesystems.com', 'Emma Persky'],
    ['charles@circus-foundation.org', 'Charles Armstrong'],
    ['martin@dekstop.de', 'Martin Dittus'],
    ['smallcaps@gmail.com', 'Jef Koh'],
    ['angusprune@gmail.com', 'James Heaver']
    ].each do |(email, name)|
      Member.create(:email=>email, :name=>name) if Member.all(:email=>email).empty?
    end
  end
end