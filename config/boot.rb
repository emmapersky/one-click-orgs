require 'rubygems'
environment = File.expand_path("../../.bundle/environment.rb", __FILE__)
if File.exists?(environment)
  # locked env
  require environment
elsif File.exist?(File.expand_path('../../Gemfile', __FILE__))
  # Set up gems listed in the Gemfile.
  require 'bundler'
  Bundler.setup
end
