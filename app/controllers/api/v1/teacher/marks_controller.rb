class Api::V1::Teacher::MarksController < Api::V1::Teacher::BaseController
  before_action :set_mark, only: [:update]

  def index
    unless params[:classroom_id].present? && params[:subject_id].present?
      return render json: { error: 'classroom_id and subject_id parameters are required' }, status: :bad_request
    end

    assignment = current_userable.teacher_subject_assignments.find_by(
      classroom_id: params[:classroom_id],
      subject_id: params[:subject_id]
    )

    unless assignment
      return render json: { error: 'You are not assigned to teach this subject for this classroom' }, status: :forbidden
    end

    marks = Mark.joins(:enrollment).where(
      enrollments: { classroom_id: params[:classroom_id] }, 
      subject_id: params[:subject_id]
    )
    
    @pagy, @marks = pagy(marks)
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
