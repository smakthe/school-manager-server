class StudentSerializer
  include JSONAPI::Serializer
  attributes :name, :school_id, :dob, :gender, :admission_number, :is_active, :current_class_display
end
