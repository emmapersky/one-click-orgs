class Vote < ActiveRecord::Base
  belongs_to :member
  belongs_to :proposal
  
  def for_or_against
    Vote.for_or_against(self.for?)
  end
  
  def self.for_or_against(foa)
    foa ? "Support" : "Oppose"
  end
end
