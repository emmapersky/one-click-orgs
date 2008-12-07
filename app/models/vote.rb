require 'dm-validations'

class Vote
  include DataMapper::Resource
  belongs_to :member
  belongs_to :decision
  
  property :id, Serial
  property :for, Boolean, :nullable => false

  def for_or_against
    self.for_or_agains(self.for)
  end
  
  def self.for_or_against(foa)
    foa ? "For" : "Against"
  end
end
