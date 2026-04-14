class TeacherSerializer
  include JSONAPI::Serializer
  attributes :name, :school_id, :employee_code, :doj, :salary, :is_active, :type
  
  has_one :user
end