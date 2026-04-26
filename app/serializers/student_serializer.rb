class StudentSerializer
  include JSONAPI::Serializer
  attributes :name, :school_id, :dob, :gender, :admission_number, :is_active, :current_class_display
  
  attribute :school_name do |object|
    object.school&.name
  end

  attribute :classroom_name do |object|
    object.current_classroom&.display_name
  end
end
