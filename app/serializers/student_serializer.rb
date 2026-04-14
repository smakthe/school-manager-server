class StudentSerializer
  include JSONAPI::Serializer
  attributes :name, :school_id, :dob, :gender, :admission_number
end
