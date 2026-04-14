class ClassroomSerializer
  include JSONAPI::Serializer
  attributes :school_id, :academic_year_id, :class_teacher_id, :grade, :section, :display_name

  # Calculate the total number of students enrolled in this classroom
  attribute :students_count do |object|
    object.students.count
  end

  # Nest the basic teacher details if a class teacher is assigned
  attribute :class_teacher do |object|
    if object.class_teacher
      {
        id: object.class_teacher.id,
        name: object.class_teacher.name,
        employee_code: object.class_teacher.employee_code
      }
    end
  end
end