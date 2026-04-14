class Api::V1::Admin::DashboardController < Api::V1::Admin::BaseController
  def stats
    # 1. Top-level Counts
    total_schools = School.count
    total_teachers = Teacher.count
    total_students = Student.count

    # 2. Aggregations (Executed directly in SQL for maximum speed)
    subscription_distribution = School.group(:subscription_status).count
    gender_distribution = Student.group(:gender).count
    
    # Hiring trend grouped by year
    hiring_trend = Teacher.where.not(doj: nil).group("EXTRACT(YEAR FROM doj)").count

    # Subject distribution based on assignments
    subject_distribution = Subject.joins(:teacher_subject_assignments).group('subjects.name').count

    # Board distribution based on schools
    board_distribution = School.group(:board).count

    render json: {
      totals: {
        schools: total_schools,
        teachers: total_teachers,
        students: total_students
      },
      charts: {
        subscription_distribution: subscription_distribution,
        gender_distribution: gender_distribution,
        hiring_trend: hiring_trend,
        subject_distribution: subject_distribution,
        board_distribution: board_distribution
      }
    }
  end
end