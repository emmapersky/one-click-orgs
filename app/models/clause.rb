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
class Clause < ActiveRecord::Base
  before_create :set_started_at
  private
  def set_started_at
    self.started_at ||= Time.now.utc
  end
  public
  
  # Returns the currently active clause for the given name.
  def self.get_current(name)
    where(["name = ? AND started_at <= ? AND ended_at IS NULL", name, Time.now.utc]).first
  end
  
  after_create :end_previous
  private
  # Finds the previous open clauses for this name, and ends them.
  def end_previous
    Clause.where(["name = ? AND ended_at IS NULL and id != ?", name, self.id]).update_all(:ended_at => Time.now.utc)
  end
  public
  
  def to_s
    "#{name}: #{text_value || integer_value || boolean_value}"
  end
  
  def self.exists?(name)
    !!get_current(name)
  end
  
  def self.set_text(name, value)
    Clause.create!(:name => name.to_s, :text_value => value)
  end
  
  def self.get_text(name)
    v = Clause.get_current(name.to_s)
    (v ? v.text_value : nil)
  end
  
  def self.set_boolean(name, value)
    Clause.create!(:name => name.to_s, :boolean_value => value)
  end
  
  def self.get_boolean(name)
    v = Clause.get_current(name.to_s)
    (v ? v.boolean_value != 0 : nil)
  end
  
  def self.set_integer(name, value)
    Clause.create!(:name => name.to_s, :integer_value => value)
  end

  def self.get_integer(name)
    v = Clause.get_current(name.to_s)
    (v ? v.integer_value : nil)
  end
end
