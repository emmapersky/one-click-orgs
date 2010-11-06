class OcoMailer < ActionMailer::Base
  helper :application
  default :from => "info@oneclickorgs.com"

  class EmailJob
    attr_reader :mail

    def initialize(mail)
      @mail = mail.encoded
    end

    def perform
      message = Mail::Message.new(mail)
      ActionMailer::Base.wrap_delivery_behavior(message)
      message.deliver!
    end
  end

  def self.deliver_mail(mail)
    if worker_running?
      Delayed::Job.enqueue EmailJob.new(mail)
    else
      Rails.logger.debug "Worker not running, falling back to direct sending"
      super
    end
  end

  def self.worker_running?
    pid_file = File.join(Rails.root, 'tmp', 'pids', 'delayed_job.pid')
    return false unless File.exist? pid_file
    pid = IO.read(pid_file).strip.to_i
    begin
      !!Process.kill(0, pid)
    rescue Errno::ESRCH
      false
    end
  end
end
