# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "1.0.8.1"
dm_gems_version   = "0.9.11"


#For more information about each component, please read http://wiki.merbivore.com/faqs/merb_components
# after updating: thor merb:gem:install && thor merb:gem:redeploy
dependency "merb-action-args", merb_gems_version
dependency "merb-assets", merb_gems_version  
dependency "merb-cache", merb_gems_version   
dependency "merb-helpers", merb_gems_version 
dependency "merb-haml", merb_gems_version 
dependency "merb-mailer", merb_gems_version  
dependency "merb-slices", merb_gems_version  
dependency "merb-auth-core", merb_gems_version
dependency "merb-auth-more", merb_gems_version
dependency "merb-auth-slice-password", merb_gems_version
dependency "merb-param-protection", merb_gems_version
dependency "merb-exceptions", merb_gems_version
dependency "merb-gen", merb_gems_version
 
dependency "dm-core", dm_gems_version         
dependency "dm-aggregates", dm_gems_version   
dependency "dm-migrations", dm_gems_version   
dependency "dm-timestamps", dm_gems_version   
dependency "dm-types", dm_gems_version        
dependency "dm-validations", dm_gems_version  

dependency "do_mysql", "0.9.11"
#if you are having problems, you can install this locally with this line on os x
#sudo gem install do_mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config 

dependency "merb_datamapper", merb_gems_version

dependency "faker", "0.3.1"
dependency "haml", "2.0.9"
dependency "rspec", "1.1.12", :require_as => nil
dependency "rack", "1.0.0"
dependency "fastthread", "1.0.7"
dependency "gem_plugin", "0.2.3"
dependency "cgi_multipart_eof_fix", "2.5.0"
dependency "mongrel", "1.1.5"
dependency "data_objects", "0.9.11"
dependency "json_pure", "1.1.7", :require_as => 'json'
dependency "daemons", "1.0.10"
dependency "ZenTest", >= "4.1.3", :require_as => 'zentest'
dependency "ruby_parser", "2.0.3"
 
# need to add gem sources for these
# $ gem sources -a http://gems.github.com 
dependency "snepo-dm-machinist", :require_as => 'dm-machinist'
