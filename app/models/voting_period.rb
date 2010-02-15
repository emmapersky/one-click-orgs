module VotingPeriods
  PERIODS = [1800, 86400, 172800, 259200, 604800, 1209600] # in seconds
  
  def self.name_for_value(value)
    value = value.to_i
    case value
    when 0..3600
      minutes = (value / 60.0).round
      if minutes == 1
        "1 minute"
      else
        "#{minutes} minutes"
      end
    when 3601..(86400 * 5)
      hours = (value / 3600.0).round
      if hours == 1
        "1 hour"
      else
        "#{hours} hours"
      end
    else
      weeks = (value / (3600.0 * 24 * 7)).round
      if weeks == 1
        "1 week"
      else
        "#{weeks} weeks"
      end
    end
  end
  
  def self.all(&block)
    returning(
      PERIODS.map{|p| {:name => name_for_value(p), :value => p}}
    ) do |periods|
      periods.each(&block) if block
    end      
  end
end
