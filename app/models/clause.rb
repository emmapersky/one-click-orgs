# Represents the clauses in the constitution which may be modified by the user.
# 
# The current necessary clauses are:
# 
# Name                        Value
# 
# organisation_name           String
# organisation_objectives     String
# assets                      Boolean
# voting_period               Integer representing one of the options
# general_voting_system       String -- the class name of the VotingSystem in use
# membership_voting_system    String -- the class name of the VotingSystem in use
# constitution_voting_system  String -- the class name of the VotingSystem in use
class Clause < ActiveRecord::Base
  belongs_to :organisation

  validates_presence_of :name
  # TODO: validate presence of exactly one of the value columns
  validate(:on => :create) do |c|
    errors.add('One of boolean_value, integer_value or text_value', 'cannot be empty') if [c.boolean_value, c.integer_value, c.text_value].all?(&:blank?)
  end

  scope :current, where('ended_at IS NULL')
  
  before_create :set_started_at
  private
  def set_started_at
    self.started_at ||= Time.now.utc
  end
  public
  
  # Returns the currently active clause for the given name.
  def self.get_current(name)
    current.where(["name = ? AND started_at <= ?", name, Time.now.utc]).first
  end
  
  after_create :end_previous
  private
  # Finds the previous open clauses for this name, and ends them.
  def end_previous
    organisation.clauses.current.where(["name = ? AND id != ?", name, self.id]).update_all(:ended_at => Time.now.utc)
  end
  public
  
  def to_s
    "#{name}: #{text_value || integer_value || boolean_value}"
  end
  
  def self.exists?(name)
    !!get_current(name)
  end
  
  def self.set_text(name, value)
    create!(:name => name.to_s, :text_value => value)
  end
  
  def self.get_text(name)
    v = get_current(name.to_s)
    (v ? v.text_value : nil)
  end
  
  def self.set_boolean(name, value)
    create!(:name => name.to_s, :boolean_value => value)
  end
  
  def self.get_boolean(name)
    v = get_current(name.to_s)
    (v ? v.boolean_value != 0 : nil)
  end
  
  def self.set_integer(name, value)
    create!(:name => name.to_s, :integer_value => value)
  end

  def self.get_integer(name)
    v = get_current(name.to_s)
    (v ? v.integer_value : nil)
  end
end
