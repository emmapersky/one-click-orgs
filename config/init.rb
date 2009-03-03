# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
require 'sass'
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'cccf61526b3a7beffe6b120432ae00c1640a60fe'  # required for cookie session store
  c[:session_id_key] = '_one_click_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::Plugins.config[:sass][:style] = :compact
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  require 'lib/smtp_tls'
  require 'lib/find_by_sql_hack'
  # This will get executed after your app's classes have been loaded.
  require 'config/local_config'
  
  Merb.run_later do
    while true do
      Merb.logger.debug("running Decision.close_early_decisions()")            
      Decision.close_early_decisions
      sleep 60
    end
  end unless Merb.testing?
end