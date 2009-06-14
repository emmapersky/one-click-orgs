require 'dm-validations'

class Decision
  include DataMapper::Resource
  
#  after :create, :send_email
  property :id, Serial  
  belongs_to :proposal 
end