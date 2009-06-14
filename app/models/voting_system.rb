module VotingSystems  

  class VotingSystem
    def self.can_be_closed_early?(proposal)
      false
    end
    
    def self.passed?(proposal)
      raise NotImplementedError      
    end
  end
  
  
  class RelativeMajority < VotingSystem
    def self.can_be_closed_early?(proposal)
      proposal.votes_for > (proposal.total_members  / 2.0).ceil
    end
    
    def self.passed?(proposal)
      proposal.votes_for > proposal.votes_against      
    end
  end
  
  class Veto < VotingSystem
    def self.passed?(proposal)
      proposal.votes_against == 0
    end
  end
  

  class Majority < VotingSystem
    
    def self.initialize(fraction_needed)
      @fraction_needed = fraction_needed
    end
    
    def self.passed?(proposal)
      proposal.votes_for / proposal.total_members.to_f >= @fraction_needed
    end
  end
  
  class AbsoluteMajority < Majority
    def self.initialize; super(0.5); end
  end
  
  class AbsoluteTwoThirdsMajority < Majority
    def self.initialize; super(2.0/3.0); end
  end
  
  class Unanimous < Majority
    def self.initialize; super(1.0); end
  end
end



