class MemberClass < ActiveRecord::Base
  belongs_to :organisation
  has_many :members

  validates_presence_of :name
  
  def has_permission(type)
    organisation.clauses.get_boolean(get_permission_name(type)) || false
  end
  
  def set_permission(type, value)
    organisation.clauses.set_boolean(get_permission_name(type), value)
  end
  
private
  
  def get_permission_name(type)
    "permission_#{self.name.underscore}_#{type.to_s.underscore}"
  end
end
