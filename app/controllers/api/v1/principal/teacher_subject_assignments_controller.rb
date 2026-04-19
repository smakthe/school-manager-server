class Api::V1::Principal::TeacherSubjectAssignmentsController < Api::V1::Principal::BaseController
  def index
    if params[:classroom_id].present?
      scope = TeacherSubjectAssignment.includes(:teacher, :subject)
                                      .where(classroom_id: params[:classroom_id])
    elsif params[:teacher_id].present?
      scope = TeacherSubjectAssignment.includes(:classroom, :subject)
                                      .where(teacher_id: params[:teacher_id])
    else
      return render json: { error: 'classroom_id or teacher_id parameter is required' }, status: :bad_request
    end

    @pagy, @assignments = pagy(scope)
    render_jsonapi(TeacherSubjectAssignmentSerializer, @assignments, pagy: @pagy)
  end
end
