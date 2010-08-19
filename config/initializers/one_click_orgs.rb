module OneClickOrgs
  VERSION = "0.6.1alpha"
  
  def self.version
    if VERSION =~ /^0/
      VERSION + " (beta)"
    else
      VERSION
    end
  end
end
