class TeacherSubjectAssignmentSerializer
  include JSONAPI::Serializer
  attributes :classroom_id, :academic_year_id

  # Return nested Subject info
  attribute :subject do |object|
    if object.subject
      { id: object.subject.id, name: object.subject.name, code: object.subject.code }
    end
  end

  # Return nested Teacher info
  attribute :teacher do |object|
    if object.teacher
      { id: object.teacher.id, name: object.teacher.name, employee_code: object.teacher.employee_code }
    end
  end
end