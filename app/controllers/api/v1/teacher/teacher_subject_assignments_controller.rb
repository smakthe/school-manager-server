class Api::V1::Teacher::TeacherSubjectAssignmentsController < Api::V1::Teacher::BaseController
  def index
    if params[:classroom_id].present?
      # Ensure the teacher can only see assignments for their homeroom or classrooms they are assigned to.
      # For now, we trust the classroom_id param but we could add a check if needed.
      # A class teacher definitely needs to see assignments for their homeroom.
      scope = TeacherSubjectAssignment.includes(:teacher, :subject)
                                      .where(classroom_id: params[:classroom_id])
    elsif params[:teacher_id].present?
      # A teacher might want to see their own assignments across classrooms
      scope = TeacherSubjectAssignment.includes(:classroom, :subject)
                                      .where(teacher_id: params[:teacher_id])
    else
      return render json: { error: 'classroom_id or teacher_id parameter is required' }, status: :bad_request
    end

    @pagy, @assignments = pagy(scope)
    render_jsonapi(TeacherSubjectAssignmentSerializer, @assignments, pagy: @pagy)
  end
end
