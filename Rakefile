require 'rubygems'
require 'rake/rdoctask'

require 'merb-core'
require 'merb-core/tasks/merb'

include FileUtils

# Load the basic runtime dependencies; this will include 
# any plugins and therefore plugin rake tasks.
init_env = ENV['MERB_ENV'] || 'rake'
Merb.load_dependencies(:environment => init_env)
     
# Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each { |r| require r } 

# Load any app level custom rakefile extensions from lib/tasks
tasks_path = File.join(File.dirname(__FILE__), "lib", "tasks")
rake_files = Dir["#{tasks_path}/*.rake"]
rake_files.each{|rake_file| load rake_file }

desc "Start runner environment"
task :merb_env do
  Merb.start_environment(:environment => init_env, :adapter => 'runner')
end

require 'spec/rake/spectask'
require 'merb-core/test/tasks/spectasks'
desc 'Default: run spec examples'
task :default => 'spec'

##############################################################################
# ADD YOUR CUSTOM TASKS IN /lib/tasks
# NAME YOUR RAKE FILES file_name.rake
##############################################################################
Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end
Rake.application.remove_task 'spec:coverage'

namespace :spec do
  desc "Run specs and check coverage with rcov"
  Spec::Rake::SpecTask.new('coverage') do |t|
    t.spec_opts = SPEC_OPTS
    t.spec_files = Dir['spec/**/*_spec.rb'].sort
    t.libs = ['lib', 'server/lib' ]
    t.rcov = true
    t.rcov_opts = ["--exclude 'config,spec,#{Gem::path.join(',')},gems,merb/'"]
    end
end


