module OneClickOrgs
  VERSION = "0.8.0alpha"
  
  def self.version
    if VERSION =~ /^0/
      VERSION + " (beta)"
    else
      VERSION
    end
  end
end
