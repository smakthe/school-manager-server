class Api::V1::Principal::MarksController < Api::V1::Principal::BaseController
  def index
    unless params[:student_id].present?
      return render json: { error: 'student_id parameter is required' }, status: :bad_request
    end

    # Fetch all marks for the student through their enrollments, scoped to the current school
    # (assuming Principal::BaseController enforces school context via RoleAuthorizable)
    student = current_school.students.find(params[:student_id])
    scope = Mark.joins(:enrollment).where(enrollments: { student_id: student.id })
    
    @pagy, @marks = pagy(scope)
    render_jsonapi(MarkSerializer, @marks, pagy: @pagy)
  end
end
