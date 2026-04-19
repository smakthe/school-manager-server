class Api::V1::Principal::DashboardController < Api::V1::Principal::BaseController
  def stats
    school = current_school

    total_classrooms = school.classrooms.count
    total_teachers   = school.teachers.count
    total_students   = school.students.count

    gender_distribution = school.students.group(:gender).count

    hiring_trend = school.teachers
                         .where.not(doj: nil)
                         .group("EXTRACT(YEAR FROM doj)")
                         .count

    subject_distribution = Subject
                             .joins(:teacher_subject_assignments)
                             .where(school_id: school.id)
                             .group("subjects.name")
                             .count

    render json: {
      totals: {
        classrooms: total_classrooms,
        teachers:   total_teachers,
        students:   total_students
      },
      charts: {
        gender_distribution:  gender_distribution,
        hiring_trend:         hiring_trend,
        subject_distribution: subject_distribution
      }
    }
  end
end
