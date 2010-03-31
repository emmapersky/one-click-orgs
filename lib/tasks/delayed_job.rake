namespace :jobs do
  desc "Start a delayed_job worker."
  task :work => :environment do
    Rails::Application.reload_routes!
    Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
  end
  
  desc "Run the outstanding jobs, then quit."
  task :run_and_quit => :environment do
    Rails::Application.reload_routes!
    Delayed::Job.work_off
  end
end
