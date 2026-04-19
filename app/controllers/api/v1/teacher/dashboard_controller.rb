class Api::V1::Teacher::DashboardController < Api::V1::Teacher::BaseController
  def stats
    teacher = current_userable

    # Assignments: each classroom+subject pair this teacher teaches
    assignments = teacher.teacher_subject_assignments
                         .includes(:classroom, :subject)
                         .to_a

    # Unique classrooms this teacher teaches in
    taught_classrooms = assignments.map(&:classroom).uniq.compact

    # Homeroom class (may be nil if not a class teacher)
    homeroom = teacher.homeroom

    # Total students across all taught classrooms (de-duped)
    student_ids = Student.joins(:enrollments)
                         .where(enrollments: { classroom_id: taught_classrooms.map(&:id) })
                         .distinct
                         .pluck(:id)
    total_students = student_ids.size

    # Performance: average score per subject this teacher teaches
    subject_performance = assignments.map do |a|
      avg = Mark.joins(:enrollment)
                .where(enrollments: { classroom_id: a.classroom_id }, subject_id: a.subject_id)
                .average(:score)
      {
        subject:   a.subject.name,
        classroom: a.classroom.display_name,
        average:   avg ? avg.round(1) : nil
      }
    end

    # Roster: group assignments by classroom for the weekly calendar
    roster = taught_classrooms.map do |classroom|
      classroom_assignments = assignments.select { |a| a.classroom_id == classroom.id }
      {
        classroom_id:   classroom.id,
        classroom_name: classroom.display_name,
        grade:          classroom.grade,
        section:        classroom.section,
        subjects:       classroom_assignments.map { |a| { id: a.subject_id, name: a.subject.name, code: a.subject&.code } }
      }
    end

    render json: {
      totals: {
        taught_classrooms: taught_classrooms.size,
        total_students:    total_students,
        total_subjects:    assignments.map { |a| a.subject.name }.uniq.size
      },
      homeroom: homeroom ? {
        id:           homeroom.id,
        display_name: homeroom.display_name,
        grade:        homeroom.grade,
        section:      homeroom.section
      } : nil,
      subject_performance: subject_performance,
      roster:              roster
    }
  end
end
