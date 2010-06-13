class MemberClass < ActiveRecord::Base
  
  def has_permission(type)
    Clause.get_boolean(get_permission_name(type)) || false
  end
  
  def set_permission(type, value)
    Clause.set_boolean(get_permission_name(type), value)
  end
  
private
  
  def get_permission_name(type)
    "permission_#{self.name.underscore}_#{type.to_s.underscore}"
  end
end
