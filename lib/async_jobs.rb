
require 'drb'
require 'thread'

# To use in a controller:
# 
#   include AsyncJobs
# 
# then, in a method:
#
#    async_job(:method_name, args ...)
#
# implement self.method_name, and it'll be called in another process.
#
# For periodic jobs, call
#
#    AsyncJobs.periodical ClassName, 5, :method_name
#
# (where 5 is the delay in seconds between invokations)


# Where the DRb socket will live
ASYNC_JOB_UNIX_SOCKET_BASE = '/tmp/oneclick_async___' # database name is appended


module AsyncJobs
  @@async_job_connection = nil
  @@async_periodic_jobs = Array.new
  
  # For use in controllers
  def async_job(method_name, *args)
    if Merb.env =~ /test/
      self.class.send(method_name, *args)
    else
      AsyncJobs.async_job(self.class.name, method_name, *args)
    end
  end
  
  # Generic use
  def self.async_job(klass_name, method_name, *args)
    retries = 3
    begin
      begin
        # Connect to the server, and ping it to make sure it's running.
        # If this fails, fork and start a server.
        @@async_job_connection ||= DRbObject.new_with_uri(AsyncJobs.drb_url)
        raise "Bad connection" unless @@async_job_connection.ping == :ping
      rescue => e
        # Connection failed, try to start a server automatically
        server_pid = Process.fork do
          Process.setsid
          AsyncJobs.async_job_server
        end
        Process.detach(server_pid)
        sleep(0.2)  # slight hack, wait a little while for the server to start
      end

      # Run job in remote server
      @@async_job_connection.job(klass_name, method_name, args)
          
    rescue => e
      # Only retry this a few times
      retries -= 1
      if retries > 0
        # Clear connection so a new connection will be created
        @@async_job_connection = nil
        retry
      else
        raise
      end
    end
  end
  
  def self.periodical(klass, delay, method_name)
    @@async_periodic_jobs << [klass.name, delay, method_name]
  end
  
  def self.async_job_server
    # Reload classes if we're not running in production
    Merb::BootLoader::ReloadClasses.run unless Merb.environment == "production"
    # Flag for termination
    terminate_server = false
    # Run service
    job_server = JobServer.new
    drb_server = DRb.start_service(self.drb_url, job_server)
    # Signal handling
    ['TERM','INT'].each do |signame|
      Signal.trap(signame) do
        drb_server.stop_service
        terminate_server = true
      end
    end
    # Trigger the periodic jobs from a thread
    @@async_periodic_jobs.each do |klass_name, delay, method_name|
      Thread.new do
        while ! terminate_server
          sleep delay
          job_server.job klass_name, method_name, []
        end
      end
    end
    # Wait for completion
    DRb.thread.join
    # Clean up
    File.unlink self.drb_socket
  end
  
  def self.drb_socket
    # Create a URL based on a UNIX socket using the database name to make something relatively unique
    # (is this the best way to find the database name?)
    ASYNC_JOB_UNIX_SOCKET_BASE + repository(:default).adapter.uri.path.gsub(/[^a-zA-Z0-9]/,'_')
  end
  
  def self.drb_url
    'drbunix:'+self.drb_socket
  end
  
  def self.ensure_worker_process_running
    AsyncJobs.async_job 'AsyncJobs', :do_absolutely_nothing
  end
  
  def self.do_absolutely_nothing
    nil
  end

private
  # ================ SERVER IMPLEMENTATION ================
  class JobServer
    def initialize
      # Mutex so only one job runs at once
      @lock = Mutex.new
    end
    
    def ping
      :ping
    end
    
    def job(klass_name, method_name, args)
      klass = Kernel.const_get(klass_name.to_sym)      
      Thread.new do
        @lock.synchronize do
          begin
            # Log job
            Merb.logger.info("async_job: #{klass_name}##{method_name} with args #{args.inspect}")
            
            # Perform the method
            klass.send(method_name, *args)
            
            # Dump any emails sent, if in development mode
            if Merb.environment == "development"
              emails = Merb::Mailer.deliveries
              unless emails.empty?
                puts " ============== EMAILS SENT =============="
                emails.each { |e| puts e.inspect }
                puts " (#{emails.length} emails)"
                emails.clear
              end
            end
          rescue => e
            Merb.logger.error("async_job error: #{klass_name}##{method_name} with exception #{e.inspect}")
          end
        end
      end
    end
    
  end

end


