require 'dm-validations'

class Vote
  include DataMapper::Resource
  belongs_to :member
  belongs_to :proposal
  
  property :id, Serial
  property :for, Boolean, :nullable => false
  property :created_at, DateTime
  
  def for_or_against
    Vote.for_or_against(self.for)
  end
  
  def self.for_or_against(foa)
    foa ? "Support" : "Oppose"
  end
end
