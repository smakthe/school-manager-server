class ClassroomSerializer
  include JSONAPI::Serializer
  attributes :school_id, :academic_year_id, :class_teacher_id, :grade, :section, :display_name
end
