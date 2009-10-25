require 'dm-validations'

# Represents the clauses in the constitution which may be modified by the user.
# 
# The current necessary clauses are:
# 
# Name                        Value
# 
# organisation_name           String
# objectives                  String
# assets                      Boolean
# domain                      String
# voting_period               Integer representing one of the options
# general_voting_system       String -- the class name of the VotingSystem in use
# membership_voting_system    String -- the class name of the VotingSystem in use
# constitution_voting_system  String -- the class name of the VotingSystem in use

class Clause
  include DataMapper::Resource
  
  property :id, Serial
  
  property :name, String, :nullable => false
  
  property :started_at, DateTime, :default => Proc.new {|r,p| Time.now.utc.to_datetime}
  property :ended_at, DateTime
  
  property :text_value, Text
  property :integer_value, Integer
  property :boolean_value, Boolean
  
  # Returns the currently active clause for the given name.
  def self.get_current(name)
    first(:name => name, :started_at.lte => Time.now.utc, :ended_at => nil)
  end
  
  after :create, :end_previous
  # Finds the previous open clauses for this name, and ends them.
  def end_previous
    Clause.all(:name => name, :ended_at => nil, :id.not => self.id).update!(:ended_at => Time.now.utc)
  end
  
  def to_s
    "#{name}: #{text_value || integer_value || boolean_value}"
  end
  
  def self.exists?(name)
    !!get_current(name)
  end
  
  def self.set_text(name, value)
    Clause.create!(:name => name.to_s, :text_value => value)
  end
  
  def self.get_text(name, value)
    v = Clause.get_current(name.to_s)
    (v ? v.text_value : nil)
  end
  
  def self.set_boolean(name, value)
    Clause.create!(:name => name.to_s, :boolean_value => value)
  end
  
  def self.get_boolean(name, value)
    v = Clause.get_current(name.to_s)
    (v ? v.boolean_value : nil)
  end
  
  def self.set_integer(name, value)
    Clause.create!(:name => name.to_s, :integer_value => value)
  end

  def self.get_integer(name, value)
    v = Clause.get_current(name.to_s)
    (v ? v.integer_value : nil)
  end
end
