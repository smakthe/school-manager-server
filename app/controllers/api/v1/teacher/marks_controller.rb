class Api::V1::Teacher::MarksController < Api::V1::Teacher::BaseController
  before_action :set_mark, only: [:update]

  def index
    unless params[:student_id].present?
      return render json: { error: 'student_id parameter is required' }, status: :bad_request
    end

    student = current_school.students.find_by(id: params[:student_id])
    unless student
      return render json: { error: 'Student not found' }, status: :not_found
    end

    enrolled_classroom_ids = Enrollment.where(student_id: student.id)
                                      .pluck(:classroom_id)

    teaches_in_classroom = current_userable.teacher_subject_assignments
                                            .where(classroom_id: enrolled_classroom_ids)
                                            .exists?

    is_class_teacher = Classroom.where(class_teacher_id: current_userable.id)
                                .where(id: enrolled_classroom_ids)
                                .exists?

    unless teaches_in_classroom || is_class_teacher
      return render json: { error: 'Forbidden: student is not in any of your classrooms' }, status: :forbidden
    end

    scope = Mark.joins(:enrollment).where(enrollments: { student_id: student.id })
    @pagy, @marks = pagy(scope)
    render_jsonapi(MarkSerializer, @marks, pagy: @pagy)
  end

  def create
    @mark = Mark.new(mark_params)
    
    unless permitted_to_modify?(@mark)
      return render json: { error: 'Not authorized to submit marks for this class/subject' }, status: :forbidden
    end

    if @mark.save
      render json: MarkSerializer.new(@mark).serializable_hash, status: :created
    else
      render_errors(@mark)
    end
  end

  def update
    unless permitted_to_modify?(@mark)
      return render json: { error: 'Not authorized to submit marks for this class/subject' }, status: :forbidden
    end

    if @mark.update(mark_params)
      render_jsonapi(MarkSerializer, @mark)
    else
      render_errors(@mark)
    end
  end

  private

  def set_mark
    @mark = Mark.find(params[:id])
  end

  def permitted_to_modify?(mark)
    # The teacher can only create/update a mark if they teach that Subject to that Student's Classroom
    enrollment = mark.enrollment || Enrollment.find_by(id: mark_params[:enrollment_id])
    subject_id = mark.subject_id || mark_params[:subject_id]
    
    return false unless enrollment && subject_id

    current_userable.teacher_subject_assignments.exists?(
      classroom_id: enrollment.classroom_id,
      subject_id: subject_id
    )
  end

  def mark_params
    params.require(:mark).permit(:enrollment_id, :subject_id, :term, :score, :max_score)
  end
end
