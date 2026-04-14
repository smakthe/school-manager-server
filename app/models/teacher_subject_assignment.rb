class TeacherSubjectAssignment < ApplicationRecord
  belongs_to :teacher
  belongs_to :classroom
  belongs_to :subject
  belongs_to :academic_year

  validates :subject_id, uniqueness: {
    scope: [:classroom_id, :academic_year_id],
    message: "already has a teacher assigned for this classroom and year"
  }

  # Convenience: confirm this is the teacher's homeroom class
  def homeroom_assignment?
    classroom.class_teacher_id == teacher_id
  end
end