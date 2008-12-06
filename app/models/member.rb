require 'dm-validations'

class Member
  include DataMapper::Resource
  has n, :votes
  
  property :id, Serial
  property :email, String, :nullable => false
  property :name, String

end
