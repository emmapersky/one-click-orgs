require 'dm-validations'

class Decision
  include DataMapper::Resource
  
  property :id, Serial  
  belongs_to :proposal 
  
  def to_event
    { :timestamp => self.proposal.close_date, :object => self, :kind => :decision }    
  end
end