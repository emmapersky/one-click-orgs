namespace :oco do
  desc "Generate installation-specific config files for One Click Orgs."
  task :generate_config do
    require 'fileutils'
    
    # Returns an absolute filename given path elements relative to the config directory
    def config_dir(*path_elements)
      path_elements.unshift(File.expand_path('../../../config', __FILE__))
      File.join(path_elements)
    end
    
    if File.exist? config_dir('database.yml')
      STDOUT.puts "config/database.yml already exists"
    else
      STDOUT.puts "Creating config/database.yml"
      FileUtils.cp config_dir('database.yml.sample'), config_dir('database.yml')
    end
    
    if File.exist? config_dir('initializers', 'local_settings.rb')
      STDOUT.puts "config/initializers/local_settings.rb already exists"
    else
      STDOUT.puts "Creating config/initializers/local_settings.rb"
      FileUtils.cp config_dir('initializers', 'local_settings.rb.sample'), config_dir('initializers', 'local_settings.rb')
      
      require 'active_support/secure_random'
      code = File.read(config_dir('initializers', 'local_settings.rb'))
      code.sub!('FIRST_SECRET_HERE', ActiveSupport::SecureRandom.hex(64))
      code.sub!('SECOND_SECRET_HERE', ActiveSupport::SecureRandom.hex(64))
      File.open(config_dir('initializers', 'local_settings.rb'), 'w'){|file| file << code}
    end
  end
  
  namespace :constitution do 
    desc "Create clauses for a default constitution. Set ORGANISATION_NAME to specify the organisation name, and OBJECTIVES to specify the objectives."
    task :create => :environment do
      organisation_name = ENV['ORGANISATION_NAME'] || "My Organisation"
      objectives = ENV['OBJECTIVES'] || ""
      domain = ENV['DOMAIN'] || "http://oco.example.com"
      
      Clause.create(:name => 'organisation_name', :text_value => organisation_name)
      Clause.create(:name => 'objectives', :text_value => objectives)
      Clause.create(:name => 'assets', :boolean_value => true)
      Clause.create(:name => 'domain', :text_value => domain)
      Clause.create(:name => 'voting_period', :integer_value => 3 * 86400)
      Clause.create(:name => 'general_voting_system', :text_value => "RelativeMajority")
      Clause.create(:name => 'organisation_state', :text_value => "active")
      Clause.create(:name => 'membership_voting_system', :text_value => "RelativeMajority")
      Clause.create(:name => 'constitution_voting_system', :text_value => "RelativeMajority")
    end
    
    task :destroy => :environment do
      Clause.all.each { |c| c.destroy }
    end
    
    task :display => :environment do
      Clause.all.each { |c| puts c }
    end
  end
  
  namespace :users do
    desc "create default users"
    task :create => :environment do
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
end
