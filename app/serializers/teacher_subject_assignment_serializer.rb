class TeacherSubjectAssignmentSerializer
  include JSONAPI::Serializer
  attributes :classroom_id, :academic_year_id

  attribute :subject do |object|
    if object.subject
      { id: object.subject.id, name: object.subject.name, code: object.subject.code }
    end
  end

  attribute :teacher do |object|
    if object.teacher
      { id: object.teacher.id, name: object.teacher.name, employee_code: object.teacher.employee_code }
    end
  end

  attribute :classroom do |object|
    if object.classroom
      { id: object.classroom.id, display_name: object.classroom.display_name, grade: object.classroom.grade, section: object.classroom.section }
    end
  end
end