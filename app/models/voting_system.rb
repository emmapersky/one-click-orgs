module VotingSystems  
  
  def self.get(klass)
    raise ArgumentError, "empty argument" if klass.nil?    
    begin
      const_get(klass.to_s) 
    rescue NameError
      nil
    end
  end
  

  class VotingSystem
    
    def self.simple_name
      self.name.split('::').last
    end
    
    def self.description(text=nil)
      @description = text if text
      @description
    end
    
    def self.long_description(text=nil)
      @long_description = text if text
      @long_description
    end
    
    def self.can_be_closed_early?(proposal)
      false
    end
    
    
    def self.passed?(proposal)
      raise NotImplementedError      
    end
  end
  
  
  class RelativeMajority < VotingSystem
    description "More supporting votes than opposing votes"
    long_description "Supporting Votes from more than half of the Members during the Voting Period; " +
      "or when more Supporting Votes than Opposing Votes have been received for the Proposal at the end of the Voting Period."
    
    
    def self.can_be_closed_early?(proposal)
      proposal.votes_for > (proposal.member_count  / 2.0).ceil
    end
    
    def self.passed?(proposal)
      proposal.votes_for > proposal.votes_against      
    end
  end
  
  class Veto < VotingSystem
    description "No opposing votes"
    long_description "no Opposing Votes during the Voting Period."
    
    def self.passed?(proposal)
      proposal.votes_against == 0
    end
  end
  

  class Majority < VotingSystem      
    def self.fraction_needed=(f)
      @fraction_needed = f
    end
    
    def self.initialize(fraction_needed)
      @fraction_needed = fraction_needed
    end
    
    def self.passed?(proposal)
      proposal.votes_for / proposal.member_count.to_f >= @fraction_needed
    end
  end
  
  class AbsoluteMajority < Majority
    description "Supporting votes from more than half the members"
    long_description"Supporting Votes from more than half of Members during the Voting Period."
    
    self.fraction_needed = 0.5
  end
  
  class AbsoluteTwoThirdsMajority < Majority
    description "Supporting votes from more than two thirds of the members"
    long_description "Supporting Votes from more than two thirds of Members during the Voting Period."
    
    self.fraction_needed = 2.0/3.0
  end
  
  class Unanimous < Majority
    description "Supporting votes from every single member"
    long_description "Supporting Votes from all Members during the Voting Period."
    self.fraction_needed = 1.0
  end
  
  def self.all(&block)
    returning(
      [
        RelativeMajority,
        AbsoluteMajority,
        AbsoluteTwoThirdsMajority,
        Unanimous,
        Veto
      ]
      ) do |systems|
      systems.each(&block) if block
    end      
  end
end



