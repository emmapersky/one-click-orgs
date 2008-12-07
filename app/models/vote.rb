require 'dm-validations'

class Vote
  include DataMapper::Resource
  belongs_to :member
  belongs_to :decision
  
  property :id, Serial
  property :for, Boolean, :nullable => false

  def for_or_against
    self.for ? "For" : "Against"
  end
end
