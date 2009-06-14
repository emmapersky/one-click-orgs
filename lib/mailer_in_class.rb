
# Shameless copy of merb function to be able to send in class methods
class Application
  def self.send_mail(klass, method, mail_params, send_params = nil)
    klass.new(send_params || params, self).dispatch_and_deliver(method, mail_params)
  end
end

module OCOMail
  def self.send_mail(klass, method, mail_params, send_params = nil)
    klass.new(send_params || params, self).dispatch_and_deliver(method, mail_params)
  end
end
