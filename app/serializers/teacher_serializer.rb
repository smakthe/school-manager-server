class TeacherSerializer
  include JSONAPI::Serializer
  attributes :name, :school_id, :employee_code, :doj, :salary, :is_active
  
  has_one :user
end
