class TeacherSerializer
  include JSONAPI::Serializer
  attributes :name, :school_id, :employee_code, :doj, :salary, :is_active, :type
  
  attribute :school_name do |object|
    object.school&.name
  end

  has_one :user
end