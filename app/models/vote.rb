require 'dm-validations'

class Vote
  include DataMapper::Resource
  belongs_to :member
  belongs_to :decision
  
  property :id, Serial
  property :for, Boolean, :nullable => false

end
