class Vote < ActiveRecord::Base
  belongs_to :member
  belongs_to :proposal
  
  def for_or_against
    Vote.for_or_against(self.for?)
  end
  
  def self.for_or_against(foa)
    foa ? "Support" : "Oppose"
  end
  
  def to_event
    {:timestamp => self.created_at, :object => self, :kind => :vote }
  end
end
