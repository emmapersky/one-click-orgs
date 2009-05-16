require 'dm-validations'

class Decision
  LENGTH_OF_DECISION = 3.days
  include DataMapper::Resource
  
#  after :create, :send_email
  property :id, Serial  
  belongs_to :proposal 
end