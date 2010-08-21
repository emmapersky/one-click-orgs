# Storage for app-wide settings.
# 
# Set a setting like this:
# 
#   Setting[:base_domain] = "oneclickorgs.com"
# 
# Get a setting like this:
# 
#   Setting[:base_domain]
class Setting < ActiveRecord::Base
  def self.[](the_key)
    setting = where(:key => the_key.to_s).first
    setting ? setting.value : nil
  end
  
  def self.[]=(the_key, the_value)
    setting = where(:key => the_key.to_s).first || self.new(:key => the_key.to_s)
    setting.value = the_value
    setting.save!
    setting.value
  end
end
