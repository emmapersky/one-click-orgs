require 'rubygems'
if File.join(File.dirname(__FILE__), "bin", "common.rb")
  require File.join(File.dirname(__FILE__), "bin", "common")
end
require 'merb-core'
 
Merb::Config.setup(:merb_root   => ".",
                   :environment => ENV['RACK_ENV'],
		   :log_file => "./log/#{ENV['RACK_ENV']}.log")

Merb.environment = Merb::Config[:environment]
Merb.root = Merb::Config[:merb_root]
#Merb.log_file = Merb::Config[:log_file]

Merb::BootLoader.run
 
run Merb::Rack::Application.new
